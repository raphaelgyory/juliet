#include <boost/python.hpp>
#include <julia.h>

double call_julia_function(const char *f, const boost::python::list& args)
{
	// init
    jl_init();
    // function
    jl_function_t *func = jl_get_function(jl_base_module, f);
    // get the size of the array
    boost::python::ssize_t args_count = boost::python::len(args);
    // create empty array for julia args
    jl_value_t* *boxed_args[args_count];
    for(boost::python::ssize_t i=0;i<args_count;i++) {
        // get arg
        boost::python::object arg = args[i];
        // get its type
        boost::python::extract<double> n(arg);
        if ( n.check() ) {
            // we have a double
            // boxing
            jl_value_t *boxed_arg = jl_box_float64(n);
            boxed_args[i] = &boxed_arg;
        }
    }
    jl_value_t *ret = jl_call(func, *boxed_args, args_count);
	// exception ?
	if (jl_exception_occurred())
		printf("%s \n ", jl_typeof_str(jl_exception_occurred()));
	// unbox
    double ret_unboxed = jl_unbox_float64(ret);
    jl_atexit_hook(0);
    return ret_unboxed;
}

BOOST_PYTHON_MODULE(wrapper)
{
    using namespace boost::python;
    def("call_julia_function", call_julia_function);
}
