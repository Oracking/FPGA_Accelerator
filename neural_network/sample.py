from old_modules.old_fixed_neural_network import relu
import fixed_point as fp
import numpy as np
import fixed_neural_network as fnn

# representation = fixed_twos_complement_representation(self).__repr__()
#         start, end = representation.find("["), representation.rfind("]") + 1
#         representation = representation[start:end]


def main():
    il, fl = 7, 8
    network = fnn.Sequential(il, fl)
    layer_1 = fnn.FullyConnected(16, init="default", input_shape=3)
    layer_2 = fnn.Activation('relu')
    layer_3 = fnn.FullyConnected(16, init="default")
    layer_4 = fnn.Activation('relu')
    layer_5 = fnn.FullyConnected(3, init="default")
    layer_6 = fnn.Activation('relu')
    network.add(layer_1).add(layer_2).add(layer_3).add(layer_4).add(layer_5).add(layer_6)

    # for index, layer in enumerate(network.layers):
    #     if isinstance(layer, fnn.FullyConnected):
    #         print(f"\nWeights {index + 1}:")
    #         print(layer.weights.value.__repr__())
    #         for line in layer.weights.to_std_logic_vector():
    #             print(line)
    #         print(f"\nBiases {index + 1}:")
    #         print(layer.biases.value.__repr__())
    #         biases_value = layer.biases.value.reshape(max(layer.biases.shape))
    #         biases = fp.FixedPointArray(biases_value, IL, FL)
    #         for line in biases.to_std_logic_vector():
    #             print(line)

    fp_inputs = fp.FixedPointArray(np.array([[2219], [-441], [-1346]]), il, fl)

    fp_weights_1 = fp.FixedPointArray(
        np.array([[96, -317,   87],
                  [151, -240,  129],
                  [28, -198, -195],
                  [-252,  100,  176],
                  [-299,   94,   42],
                  [207, -343,    7],
                  [-517, -310, -212],
                  [44, -427,  191],
                  [206,  199, -111],
                  [-646,   74, -283],
                  [271, -217, -401],
                  [-176,  125,   21],
                  [314,  125,  -52],
                  [-79, -391,  -19],
                  [-451,  -42,  153],
                  [-32,   66,  -29]]),
        il, fl
    )

    fp_weights_3 = fp.FixedPointArray(
        np.array([[-6, -202,  477,  -89,  269,   91,  177,   36,  163,  314,    0,
                  -67,  453, -205, -226, -169],
                  [-112,  400,  322, -123, -285,  376,   -3, -320,  206,  454,  -70,
                  -184, -163,   37, -254, -138],
                  [138,  -19,  -33,   82,  -76,  -75,  386, -385,  -83, -141,  245,
                   131,  199,  244,   89, -153],
                  [-419, -211, -239,    9,  -35, -455,  243, -307,  233,  -69, -152,
                   216,  -53,  147,   25,    1],
                  [-2, -227, -356, -350, -181, -162,  406,  197,  156,  322, -292,
                   409,  -13,  101, -400, -280],
                  [-142, -580,   51,  542, -385,  -90, -115,  393,  403,  397,  -48,
                   125, -137,  353, -330,  112],
                  [139,  119, -432, -339, -178, -443, -258,   82,   85, -119,   -7,
                   127,  -10, -377, -171,   91],
                  [114, -460,   62,  -10,  -91,  663,  485, -128,  175, -126,  -67,
                  -193,  381, -178, -414,  -11],
                  [254,   39,  105,  231,  342, -217, -289,   38,   75,   83,  222,
                  250,   19,  156, -129, -165],
                  [663,  231,  171,  308,  230, -343,  105,  385,  256,  544,  144,
                   372,   53,  498, -235, -267],
                  [231, -248,  180,  390,  -26,  247,  430,   76, -266,  301,   42,
                   360,   72, -394,   61,  -10],
                  [165, -327,  245,   58,  182, -275, -261,  197,  213, -447, -159,
                   48,  -93,  205,  425, -515],
                  [-94,  117,  553, -192, -293, -334,  106,   77,   69,  108,  -43,
                   134,  -43,  397,  284,  -67],
                  [-44,  124,  141, -103,  -36,  187, -120, -277,  294,   -9,   35,
                   244,  182, -497,   70, -145],
                  [-98,  -42,  166, -172,   73,  406,  340,  225, -193, -277, -298,
                   214,  134, -245,  288, -158],
                  [218, -606, -198,  108,   36, -178, -243, -260, -138, -440,  615,
                   15,  -41, -242,  249, -211]]),
        il, fl
    )

    fp_weights_5 = fp.FixedPointArray(
        np.array([[-171, 125, -29, 182, 148, -51, -245, -100, 381, 242, 242,
                   -86, -266, -273, -69, -20],
                  [376, 369, -481, -157, 30, -170, -178, -80, -7, 122, -429,
                   93, -63, -66, -581, -181],
                  [11, 375, 301, -189, 623, 8, 73, 224, 72, -107, -105,
                   -481, -34, -82, -130, 11]]),
        il, fl
    )

    fp_bias_1 = fp.FixedPointArray(
        np.array([[200], [-181], [-220], [-97], [386], [-220], [91], [-1], [354],
                  [491], [183], [244], [-17], [-212], [-620], [33]]),
        il, fl
    )

    fp_bias_3 = fp.FixedPointArray(
        np.array([[311], [-25], [-188], [-143], [223], [-257], [-476], [360], [22],
                  [-113], [-37], [-55], [46], [-18], [143], [378]]),
        il, fl
    )

    fp_bias_5 = fp.FixedPointArray(
        np.array([[333],
                  [77],
                  [166]]),
        il, fl
    )

    print("\nResult: ")
    layer_1.weights, layer_1.biases = fp_weights_1, fp_bias_1
    layer_3.weights, layer_3.biases = fp_weights_3, fp_bias_3
    layer_5.weights, layer_5.biases = fp_weights_5, fp_bias_5
    
    result = network.predict(fp_inputs)
    # network.back_propagate(result)
    print(result.value)
    for line in result.to_std_logic_vector():
        print(line)


if __name__ == "__main__":
    main()
