import numpy as np


def VISTA(video, aux, l1 = 1.0, l2 = 1.0, l3 = 1.0, thres = 1e-5, maxit = 100):

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

    np.isnan()

