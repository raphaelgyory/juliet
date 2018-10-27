# -*- coding: utf-8 -*-

# https://docs.julialang.org/en/v1/manual/embedding/index.html
# julia requires the RTLD_GLOBAL option
import ctypes
import sys
flags = sys.getdlopenflags()
sys.setdlopenflags(flags | ctypes.RTLD_GLOBAL)


class Julia(object):

    def __init__(self):
        from juliet import wrapper
        self.wrapper = wrapper

    def function(self, f, *args):
        """
        @var f: the string representation of the Julia function to be called.
        """
        return self.wrapper.call_julia_function(f, list(args))
