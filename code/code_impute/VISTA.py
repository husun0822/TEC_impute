import numpy as np
from numpy.linalg import svd
from copy import deepcopy
import scipy.io as sio


def Frob_Ratio(Uold, Dsqold, Vold, U, Dsq, V):
    denom = np.sum(Dsqold ** 2)
    utu = np.diag(Dsq) @ np.transpose(U) @ Uold
    vtv = np.diag(Dsqold) @ np.transpose(Vold) @ V
    num = denom + np.sum(Dsq ** 2) - 2 * np.trace(utu @ vtv)

    return num / max(denom, 1e-9)


def VISTA(video, aux, l1=1.0, l2=1.0, l3=1.0, thresh=1e-5, maxit=100):
    # get the matrix size m-by-n and number of frames t
    m, n = video.shape[0], video.shape[1]

    # choose the hidden ranks of the factor matrices
    r = min(m, n)

    # check if the input video is just 1-frame
    if len(video.shape) != 3:
        t = 1
        l2 = 0.0
        video = np.expand_dims(video, axis=2)
        aux = np.expand_dims(aux, axis=2)
    else:
        t = video.shape[2]

    # get the missingness mask
    video_NA = np.isnan(video)
    video_fill = deepcopy(video)

    # set up storage space for U, D, V, imputed map and initialize them
    U = np.zeros(shape=(t, m, r))
    V = np.zeros(shape=(t, n, r))
    D = np.ones(shape=(t, r))
    Impute = np.zeros(shape=(t, m, n))

    for time in range(t):
        u = np.random.normal(size=(m, r))
        v = np.random.normal(size=(n, r))
        uh, _, _ = svd(u, full_matrices=False)
        vh, _, _ = svd(v, full_matrices=False)
        U[time], V[time] = uh, vh
        Impute[time] = np.dot(U[time] * D[time], np.transpose(V[time]))

    video_fill[video_NA] = 0.0  # fill the missing values as 0
    ratio = np.ones(shape=(t,))  # convergence threshold for every frame
    i = 0

    # VISTA algorithm iterations
    while ((i < maxit) and (max(ratio) > thresh)):
        i = i + 1  # update the iteration counter

        # snapshot the value of U, D, V at the current interation
        U_old, V_old, D_old, Impute_old = deepcopy(U), deepcopy(V), deepcopy(D), deepcopy(Impute)

        # U-step of VISTA algorithm
        for time in range(t):
            fill = video_fill[:, :, time]
            fill_NA = video_NA[:, :, time]

            u, dsq, v = U[time], D[time], V[time]

            # construct the smoothing term and the shrinkage parameter
            if t == 1:
                ts = 0
                const = 1 + l3
            elif (time == 1):
                ts = Impute[time + 1] * l2
                const = 1 + l2 + l3
            elif (time == (t - 1)):
                ts = Impute[time - 1] * l2
                const = 1 + l2 + l3
            else:
                ts = (Impute[time - 1] + Impute[time + 1]) * l2
                const = 1 + 2 * l2 + l3

            B = np.transpose(np.transpose(u) @ (fill + ts + l3 * aux[:, :, time])) * dsq / (const * dsq + l1)  # n-by-r
            uB, dB, vB = svd(B, full_matrices=False)
            v, dsq, u = uB, dB, u @ np.transpose(vB)
            xhat = np.dot(u * dsq, np.transpose(v))
            Impute[time] = xhat
            fill[fill_NA] = xhat[fill_NA]
            U[time], V[time], D[time], video_fill[:, :, time] = u, v, dsq, fill

        # V-step for VISTA algorithm
        for time in range(t):
            fill = video_fill[:, :, time]
            fill_NA = video_NA[:, :, time]

            u, dsq, v = U[time], D[time], V[time]

            # construct the smoothing term and the shrinkage parameter
            if t == 1:
                ts = 0
                const = 1 + l3
            elif (time == 1):
                ts = Impute[time + 1] * l2
                const = 1 + l2 + l3
            elif (time == (t - 1)):
                ts = Impute[time - 1] * l2
                const = 1 + l2 + l3
            else:
                ts = (Impute[time - 1] + Impute[time + 1]) * l2
                const = 1 + 2 * l2 + l3

            A = ((fill + ts + l3 * aux[:, :, time]) @ v) * dsq / (const * dsq + l1)  # m-by-r matrix
            uA, dA, vA = svd(A, full_matrices=False)
            u, dsq, v = uA, dA, v @ np.transpose(vA)
            xhat = np.dot(u * dsq, np.transpose(v))
            Impute[time] = xhat
            fill[fill_NA] = xhat[fill_NA]
            U[time], V[time], D[time], video_fill[:, :, time] = u, v, dsq, fill

        # check convergence criterion
        for time in range(t):
            ratio[time] = Frob_Ratio(U_old[time], D_old[time], V_old[time], U[time], D[time], V[time])

    # soft-thresholding the final output
    Impute_final = np.zeros(shape=(m, n, t))
    for time in range(t):
        u = video_fill[:, :, time] @ V[time]
        sU, sd, sV = svd(u, full_matrices=False)
        u, dsq, v = sU, sd, V[time] @ np.transpose(sV)
        dsq = np.maximum(dsq - l1, np.zeros_like(dsq))
        rout = min(np.sum(dsq > 0) + 1, r)
        Impute_final[:, :, time] = np.dot(u[:, 0:rout] * dsq[0:rout], np.transpose(v[:, 0:rout]))

    return Impute_final