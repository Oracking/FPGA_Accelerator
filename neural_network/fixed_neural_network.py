import fixed_point as fp
import numpy as np
from random import shuffle
import time


class ReluActivation:
    @staticmethod
    def function(z):
        return fp.clip_value(fp.FixedPointArray(1 * z.value, z.il, z.fl), set_min=0)

    @staticmethod
    def derivative(z):
        clipped = fp.clip_value(fp.FixedPointArray(1 * z.value, z.il, z.fl), 0, 1)
        return fp.from_float_array(clipped.value, z.IL, z.FL)


class SigmoidActivation:
    @staticmethod
    def function(z):
        float_z = z.value * 2 ** - z.fl
        float_out = 1.0 / (1.0 + np.exp(-float_z))
        return fp.from_float_array(float_out, z.il, z.fl)

    @staticmethod
    def derivative(z):
        sigmoid_z = SigmoidActivation.function(z)
        result = fp.multiply_elementwise(sigmoid_z, (fp.ones(sigmoid_z.shape, z.il, z.fl) - sigmoid_z))
        return fp.stochastic_round(result, z.il, z.fl)


class Activation:
    ActivationTypes = {
        'relu': ReluActivation,
        'sigmoid': SigmoidActivation
    }

    def __init__(self, activation_type):
        self.activation_type = Activation.ActivationTypes[activation_type.lower()]
        self.history = None
        self.input_shape = None

    def feedforward(self, layer_input, batch_size=1):
        self.history = z = layer_input
        return self.predict(layer_input, batch_size)

    def predict(self, layer_input, batch_size=1):
        result = self.activation_type.function(layer_input)
        return fp.stochastic_round(result, result.IL, result.FL)

    def back_propagate(self, cost_derivative_at_layer):
        z_prime = self.activation_type.derivative(self.history)
        result = fp.multiply_elementwise(cost_derivative_at_layer, z_prime)
        return fp.stochastic_round(result, result.IL, result.FL)

    @property
    def output_shape(self):
        return self.input_shape


class FullyConnected:
    def __init__(self, num_neurons, init=None, input_shape=None):
        self.num_neurons = num_neurons
        self.init = init
        self.input_shape = input_shape
        self.weights = None
        self.biases = None
        self.hyper_params = None
        self.history = None
        self.delta_weights = None
        self.delta_biases = None
        self.total_batches = None

    def initialize(self):
        if self.init == "default":
            weight_array = np.random.randn(self.num_neurons, self.input_shape)
            bias_array = np.random.randn(self.num_neurons, 1)
        else:
            raise NotImplementedError("Initialization '{}' is not implemented".format(self.init))
        il, fl = fp.FixedPoint.IL, fp.FixedPoint.FL
        self.total_batches = fp.FixedPoint(0, il, fl)
        self.weights = fp.from_float_array(weight_array, il, fl)
        self.biases = fp.from_float_array(bias_array, il, fl)
        self.delta_weights = fp.ones(weight_array.shape, il, fl)
        self.delta_biases = fp.ones(weight_array.shape, il, fl)

    def feedforward(self, layer_input, batch_size=1):
        il, fl = fp.FixedPoint.IL, fp.FixedPoint.FL
        self.history = layer_input
        result = self.predict(layer_input)
        self.total_batches = self.total_batches + fp.from_float(batch_size, il, fl)
        self.total_batches = fp.stochastic_round(
            self.total_batches + fp.from_float(batch_size, il, fl),
            il,
            fl
        )
        return result

    def predict(self, layer_input, batch_size=1):
        il, fl = fp.FixedPoint.IL, fp.FixedPoint.FL
        result = fp.dot(self.weights, layer_input) + self.biases  # Numpy broadcasting
        return fp.stochastic_round(result, il, fl)

    def back_propagate(self, cost_derivative_at_layer):
        dc_dl = cost_derivative_at_layer
        il, fl = fp.FixedPoint.IL, fp.FixedPoint.FL
        self.delta_weights = fp.dot(dc_dl, self.history.transpose())
        self.delta_biases = fp.dot(dc_dl, fp.ones((dc_dl.shape[1], 1), il, fl))
        back_propagated_cost = fp.dot(self.weights.transpose(), dc_dl)

        self.delta_weights = fp.stochastic_round(self.delta_weights, il, fl)
        self.delta_biases = fp.stochastic_round(self.delta_biases, il, fl)
        return fp.stochastic_round(back_propagated_cost, il, fl)

    def update_params(self):
        il, fl = fp.FixedPoint.IL, fp.FixedPoint.FL
        learning_factor = fp.stochastic_round(self.hyper_params.learning_rate / self.total_batches, il, fl)
        self.weights = fp.stochastic_round(self.weights - learning_factor * self.delta_weights, il, fl)
        self.biases = fp.stochastic_round(self.biases - learning_factor * self.delta_biases, il, fl)
        self.total_batches = fp.FixedPoint(0, il, fl)

    @property
    def output_shape(self):
        return self.num_neurons


class QuadraticCost:
    @staticmethod
    def function(prediction, expected):
        raise NotImplementedError("Cost not implemented yet")

    @staticmethod
    def derivative(prediction, expected):
        il, fl = fp.FixedPoint.IL, fp.FixedPoint.FL
        return fp.stochastic_round(prediction - expected, il, fl)


class HyperParams:
    def __init__(self):
        self.num_epochs = None
        self.learning_rate = None


class Sequential:
    def __init__(self, il, fl):
        self.hyper_params = HyperParams()
        fp.FixedPoint.IL = fp.FixedPointArray.IL = il
        fp.FixedPoint.FL = fp.FixedPointArray.FL = fl
        fp.FixedPoint.AUTO_ROUND = fp.FixedPointArray.AUTO_ROUND = False
        self.input_shape = None
        self.output_shape = None
        self.cost = None
        self.layers = []

    def add(self, layer):
        if len(self.layers) == 0:
            if layer.input_shape is None:
                raise AttributeError("The first layer must have an 'input_shape' attribute")
            self.input_shape = layer.input_shape
        else:
            layer.input_shape = self.output_shape

        if not isinstance(layer, Activation):
            layer.hyper_params = self.hyper_params
            layer.initialize()
        self.layers.append(layer)
        self.output_shape = layer.output_shape
        return self

    def predict(self, model_input, batch_size=1):
        layer_input = model_input
        for layer in self.layers:
            layer_input = layer.predict(layer_input, batch_size)
        return layer_input

    def feedforward(self, model_input, batch_size=1):
        layer_input = model_input
        for layer in self.layers:
            layer_input = layer.feedforward(layer_input, batch_size)
        return layer_input

    def back_propagate(self, model_cost, update_params=False):
        cost_derivative_at_layer = model_cost
        for layer in reversed(self.layers):
            cost_derivative_at_layer = layer.back_propagate(cost_derivative_at_layer)
            if update_params and not isinstance(layer, Activation):
                layer.update_params()

    def update_params(self):
        for layer in self.layers:
            if not isinstance(layer, Activation):
                layer.update_params()

    def evaluate(self, x_y_test):
        test_results = []
        for x, y in x_y_test:
            output = self.predict(x, 1)
            index = fp.argmax(output)
            y = y.value >> fp.FixedPoint.FL
            test_results.append((index, y))
        return sum(int(x == y) for (x, y) in test_results), len(x_y_test)

    def fit(self, x_y_train, batch_size, num_epochs, learning_rate, x_y_test=None):
        il, fl = fp.FixedPoint.IL, fp.FixedPoint.FL
        self.hyper_params.learning_rate = fp.from_float(learning_rate, il, fl)
        for epoch_number in range(num_epochs):
            shuffle(x_y_train)
            start = time.time()
            for j in range(0, len(x_y_train), batch_size):
                batch_input = fp.zeros((self.input_shape, batch_size), il, fl)
                batch_expected = fp.zeros((self.output_shape, batch_size), il, fl)
                k = 0
                for k in range(batch_size):
                    if j+k < len(x_y_train):
                        batch_input[:, k:k+1] = x_y_train[j+k][0]
                        batch_expected[:, k:k+1] = x_y_train[j+k][1]
                batch_prediction = self.feedforward(batch_input, batch_size=k)
                cost_derivative = self.cost.derivative(batch_prediction, batch_expected)
                self.back_propagate(cost_derivative, update_params=True)

            if x_y_test:
                correct, total = self.evaluate(x_y_test)
                print("Epoch {0}: {1} / {2}".format(epoch_number, correct, total))
                print("Total time: {0}".format(time.time() - start))

    def compile(self, loss):
        if loss == "default":
            self.cost = QuadraticCost
        else:
            raise NotImplementedError("Loss function '{}' is not implemented".format(loss))


if __name__ == "__main__":
    import mnist_loader

    WL = 15
    FL = 9
    IL = WL - FL

    training_data, validation_data, test_data = mnist_loader.load_data_wrapper()
    fp_training_data = [(fp.from_float_array(t[0], IL, FL), fp.from_float_array(t[1], IL, FL)) for t in training_data]
    fp_validation_data = [(fp.from_float_array(v[0], IL, FL), fp.from_float(v[1], IL, FL)) for v in validation_data]
    fp_test_data = [(fp.from_float_array(v[0], IL, FL), fp.from_float(v[1], IL, FL)) for v in test_data]

    model = Sequential(IL, FL)
    model.add(FullyConnected(50, init="default", input_shape=784))
    model.add(Activation("sigmoid"))
    model.add(FullyConnected(10, init="default"))
    model.add(Activation("sigmoid"))
    model.compile(loss="default")
    model.fit(fp_training_data, batch_size=10, num_epochs=30, learning_rate=3.0, x_y_test=fp_test_data)
