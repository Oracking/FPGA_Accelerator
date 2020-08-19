import numpy as np
import random


class FixedPoint:
    IL = 8
    FL = 8
    AUTO_ROUND = True

    @classmethod
    def min_positive_number(cls):
        return cls(1, cls.IL, cls.FL)


    def __init__(self, value, il, fl):
        self.value = value
        self.il = il
        self.fl = fl

    def value_multiply(self, other):
        return self.value * other.value

    def value_divide(self, other):
        return self.value // other.value

    def __add__(self, other):
        if isinstance(other, FixedPoint):
            result = fixed_addition(self, other)
            if self.AUTO_ROUND:
                return stochastic_round(result, self.IL, self.FL)
            return result
        raise ValueError("FixedPoint can only be added to "
                         "FixedPoint")

    def __sub__(self, other):
        if isinstance(other, FixedPoint):
            result = fixed_subtraction(self, other)
            if self.AUTO_ROUND:
                return stochastic_round(result, self.IL, self.FL)
            return result
        raise ValueError("FixedPoint can only be subtracted from "
                         "FixedPoint")

    def __mul__(self, other):
        if isinstance(other, FixedPoint):
            result = fixed_multiplication(self, other)
            if self.AUTO_ROUND:
                return stochastic_round(result, self.IL, self.FL)
            return result
        raise ValueError("FixedPoint can only be multiplied by "
                         "FixedPoint")

    def __truediv__(self, other):
        if isinstance(other, FixedPoint):
            result = fixed_division(self, other)
            if self.AUTO_ROUND:
                return stochastic_round(result, self.IL, self.FL)
            return result
        raise ValueError("FixedPoint can only be divided by "
                         "FixedPoint")

    def __floordiv__(self, other):
        return self.__truediv__(other)

    def __float__(self):
        return self.value * 2 ** - self.fl

    def __repr__(self):
        return (self.value * 2 ** - self.fl).__repr__()

    def __str__(self):
        return str(self.value * 2 ** - self.fl)


class FixedPointArray(FixedPoint):
    IL = 8
    FL = 8
    AUTO_ROUND = True

    def __init__(self, value, il, fl):
        super().__init__(value, il, fl)

    def dot(self, other):
        return self.__mul__(other)

    def to_std_logic_vector(self):
        representation = fixed_twos_complement_representation(self).__repr__()
        start, end = representation.find("["), representation.rfind("]") + 1
        representation = representation[start:end].replace("[", "(").replace("]", ")").replace(" ", "").replace("'", '"')
        return representation.split("\n")

    def __getattr__(self, attribute):
        return self.value.__getattribute__(attribute)

    def __getitem__(self, key):
        array_slice = self.value.__getitem__(key)
        if isinstance(array_slice, int):
            return FixedPoint(array_slice, self.il, self.fl)
        return FixedPointArray(array_slice, self.il, self.fl)

    def __setitem__(self, key, value):
        self.value.__setitem__(key, value)

    def transpose(self):
        return FixedPointArray(self.value.transpose(), self.il, self.fl)

    def value_multiply(self, other):
        return self.value.dot(other.value)

    def value_multiply_elementwise(self, other):
        return np.multiply(self.value, other.value)

    def value_divide(self, other):
        return self.value // other.value

    def __gt__(self, other):
        return FixedPointArray(self.value > other, self.il, self.fl)

    def __lt__(self, other):
        return FixedPointArray(self.value < other, self.il, self.fl)

    def __float__(self):
        raise TypeError("FixedPointArray cannot be cast to float")


def fixed_addition(fixed_1, fixed_2):
    if isinstance(fixed_1, FixedPointArray) or isinstance(fixed_2, FixedPointArray):
        ResultClass = FixedPointArray
    else:
        ResultClass = FixedPoint

    alignment_shift = abs(fixed_1.fl - fixed_2.fl)
    if fixed_1.fl >= fixed_2.fl:
        value = fixed_1.value + (fixed_2.value << alignment_shift)
    else:
        value = (fixed_1.value << alignment_shift) + fixed_2.value
    return ResultClass(
        value=value,
        il=max(fixed_1.il, fixed_2.il) + 1,
        fl=max(fixed_1.fl, fixed_2.fl)
    )


def fixed_subtraction(fixed_1, fixed_2):
    if isinstance(fixed_1, FixedPointArray) or isinstance(fixed_2, FixedPointArray):
        ResultClass = FixedPointArray
    else:
        ResultClass = FixedPoint

    alignment_shift = abs(fixed_1.fl - fixed_2.fl)
    if fixed_1.fl >= fixed_2.fl:
        value = fixed_1.value - (fixed_2.value << alignment_shift)
    else:
        value = (fixed_1.value << alignment_shift) - fixed_2.value
    return ResultClass(
        value=value,
        il=max(fixed_1.il, fixed_2.il) + 1,
        fl=max(fixed_1.fl, fixed_2.fl)
    )


def fixed_multiplication(fixed_1, fixed_2):
    if isinstance(fixed_1, FixedPointArray) or isinstance(fixed_2, FixedPointArray):
        ResultClass = FixedPointArray
    else:
        ResultClass = FixedPoint

    return ResultClass(
        value=fixed_1.value_multiply(fixed_2),
        il=fixed_1.il + fixed_2.il + 1,
        fl=fixed_1.fl + fixed_2.fl
    )


def dot(fixed_1, fixed_2):
    result = fixed_multiplication(fixed_1, fixed_2)
    if result.AUTO_ROUND:
        return stochastic_round(result, result.IL, result.FL)
    return result


def multiply_elementwise(fixed_1, fixed_2):
    result = FixedPointArray(
        value=fixed_1.value_multiply_elementwise(fixed_2),
        il=fixed_1.il + fixed_2.il + 1,
        fl=fixed_1.fl + fixed_2.fl
    )
    if result.AUTO_ROUND:
        return stochastic_round(result, result.IL, result.FL)
    return result


def fixed_division(fixed_1, fixed_2):
    if isinstance(fixed_1, FixedPointArray) or isinstance(fixed_2, FixedPointArray):
        ResultClass = FixedPointArray
    else:
        ResultClass = FixedPoint

    alignment_shift = abs(fixed_1.fl - fixed_2.fl)
    precision_shift = fixed_1.fl + fixed_2.il + 1
    if fixed_1.fl >= fixed_2.fl:
        value_1, value_2 = (fixed_1.value, (fixed_2.value << alignment_shift))
    else:
        value_1, value_2 = ((fixed_1.value << alignment_shift), fixed_2.value)
    result_value = (value_1 << precision_shift) // value_2
    return ResultClass(
        value=result_value,
        il=fixed_1.il + fixed_2.fl,
        fl=precision_shift
    )


def stochastic_round(fixed, il, fl):
    if isinstance(fixed, FixedPointArray):
        ResultClass = FixedPointArray
    else:
        ResultClass = FixedPoint

    rounding_bits = fixed.fl - fl
    if rounding_bits < 1:
        intermediate_fixed = ResultClass(
            value=fixed.value << rounding_bits,
            il=il,
            fl=fl
        )
    else:
        generated_bits = random.randint(0, 2**rounding_bits-1)
        intermediate_fixed = ResultClass(
            value=(fixed.value + generated_bits) >> rounding_bits,
            il=il,
            fl=fl
        )

    return clip_value(intermediate_fixed)


def clip_value(fixed, set_min=None, set_max=None):
    maximum_value = 2 ** (fixed.il + fixed.fl) - 1
    minimum_value = - maximum_value - 1

    if set_min is not None:
        minimum_value = set_min
    if set_max is not None:
        maximum_value = set_max

    if isinstance(fixed, FixedPointArray):
        np.clip(fixed.value, minimum_value, maximum_value, fixed.value)

    else:
        if fixed.value > maximum_value:
            fixed.value = maximum_value
        elif fixed.value < minimum_value:
            fixed.value = minimum_value
    return fixed


def fixed_twos_complement_representation(fixed):
    if fixed.AUTO_ROUND:
        fixed = stochastic_round(fixed, fixed.IL, fixed.FL)
    length = fixed.il + fixed.fl + 1
    return int_to_twos_complement_string(fixed.value, length)


@np.vectorize
def int_to_twos_complement_string(value, length):
    if value < 0:
        raw_representation = bin((1 << length) + value)  # https://stackoverflow.com/a/37075643
        representation = raw_representation[raw_representation.find("b")+1:]
    else:
        raw_representation = bin(value)
        representation = raw_representation[raw_representation.find("b")+1:]
        representation = "0" * (length - len(representation)) + representation
    return representation


def from_float(float_value, il, fl):
    fixed_value = int(float_value * 2**fl)
    return stochastic_round(FixedPoint(fixed_value, il, fl), il, fl)


def from_float_array(float_value, il, fl):
    fixed_value = (float_value * 2 ** fl).astype(int)
    return stochastic_round(FixedPointArray(fixed_value, il, fl), il, fl)


def ones(size, il, fl):
    return FixedPointArray(np.ones(size, dtype=int) << fl, il, fl)


def zeros(size, il, fl):
    return FixedPointArray(np.zeros(size, dtype=int), il, fl)


def argmax(fixed_1, *args):
    return np.argmax(fixed_1.value, *args)


if __name__ == "__main__":
    IL, FL = 7, 8

    FixedPoint.IL = FixedPointArray.IL = IL
    FixedPoint.FL = FixedPointArray.FL = FL
    FixedPoint.AUTO_ROUND = FixedPointArray.AUTO_ROUND = True

    farr_positive = from_float_array(np.array([[2 ** 8, 2 ** 8], [2 ** 8, 2 ** 8], [2 ** 8, 2 ** 8]]), IL, FL)
    farr_negative = from_float_array(np.array([-1 * 2 ** 10, -1 * 2 ** 10]), IL, FL)
    print(farr_positive.to_std_logic_vector())
