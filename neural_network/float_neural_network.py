import numpy as np
from random import shuffle
import time
import os


class ReluActivation:
    @staticmethod
    def function(z):
        return np.clip(z, a_min=0, a_max=None)

    @staticmethod
    def derivative(z):
        return (z > 0).astype(int)


class SigmoidActivation:
    @staticmethod
    def function(z):
        return 1.0 / (1.0 + np.exp(-z))

    @staticmethod
    def derivative(z):
        sigmoid_z = SigmoidActivation.function(z)
        return np.multiply(sigmoid_z, (1 - sigmoid_z))


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
        return self.activation_type.function(z)

    def predict(self, layer_input, batch_size=1):
        return self.feedforward(layer_input, batch_size)

    def back_propagate(self, cost_derivative_at_layer):
        z_prime = self.activation_type.derivative(self.history)
        return np.multiply(cost_derivative_at_layer, z_prime)

    @property
    def output_shape(self):
        return self.input_shape


class FullyConnected:
    def __init__(self, num_neurons, init, input_shape=None):
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
            self.weights = np.random.randn(self.num_neurons, self.input_shape)
            self.biases = np.random.randn(self.num_neurons, 1)
        else:
            raise NotImplementedError("Initialization '{}' is not implemented".format(self.init))
        self.total_batches = 0
        self.delta_weights = np.ones(self.weights.shape)
        self.delta_biases = np.ones(self.biases.shape)

    def feedforward(self, layer_input, batch_size=1):
        self.history = layer_input
        result = self.predict(layer_input)
        self.total_batches = self.total_batches + batch_size
        return result

    def predict(self, layer_input, batch_size=1):
        return np.dot(self.weights, layer_input) + self.biases  # Numpy broadcasting

    def back_propagate(self, cost_derivative_at_layer):
        dc_dl = cost_derivative_at_layer
        self.delta_weights = np.dot(dc_dl, self.history.transpose())
        self.delta_biases = np.dot(dc_dl, np.ones((dc_dl.shape[1], 1)))
        back_propagated_cost = np.dot(self.weights.transpose(), dc_dl)
        return back_propagated_cost

    def update_params(self):
        learning_factor = self.hyper_params.learning_rate / self.total_batches
        self.weights -= learning_factor * self.delta_weights
        self.biases -= learning_factor * self.delta_biases
        self.total_batches = 0

    @property
    def output_shape(self):
        return self.num_neurons


class QuadraticCost:
    @staticmethod
    def function(prediction, expected):
        raise NotImplementedError("Cost not implemented yet")

    @staticmethod
    def derivative(prediction, expected):
        return prediction - expected


class HyperParams:
    def __init__(self):
        self.num_epochs = None
        self.learning_rate = None


class Sequential:
    def __init__(self, il, fl):
        self.hyper_params = HyperParams()
        self.input_shape = None
        self.output_shape = None
        self.cost = QuadraticCost
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
            index = np.argmax(self.predict(x, 1))
            test_results.append((index, y))
        return sum(int(x == y) for (x, y) in test_results), len(x_y_test)

    def fit(self, x_y_train, batch_size, num_epochs, learning_rate, x_y_test=None):
        self.hyper_params.learning_rate = learning_rate
        for epoch_number in range(num_epochs):
            shuffle(x_y_train)
            start = time.time()
            for j in range(0, len(x_y_train), batch_size):
                batch_input = np.zeros((self.input_shape, batch_size))
                batch_expected = np.zeros((self.output_shape, batch_size))
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

    def export_as_vhdl_project(self, path=None):
        pass


if __name__ == "__main__":
    import mnist_loader

    WL = 15
    FL = 9
    IL = WL - FL

    training_data, validation_data, test_data = mnist_loader.load_data_wrapper()

    model = Sequential(IL, FL)
    model.add(FullyConnected(50, init="default", input_shape=784))
    model.add(Activation("sigmoid"))
    model.add(FullyConnected(10, init="default"))
    model.add(Activation("sigmoid"))
    model.compile(loss="default")
    model.fit(training_data, batch_size=10, num_epochs=30, learning_rate=3.0, x_y_test=test_data)

    model.export_as_vhdl_project()
