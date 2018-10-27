#include <boost/python.hpp>
#include <julia.h>
#include <iostream>
#include <string>
#include <exception>
#include <stdexcept>

char const* greet()
{
   return "hello, world";
}

// double call_julia_function(const char *f, double args, int32_t nargs) // boost::python::list&
// {
//     //jl_init_with_image("/home/raphael/Downloads/julia-1.0.0-linux-x86_64/julia-1.0.0/lib/julia", "sys.so");
//     jl_init();
//     //(void)jl_eval_string("println(sqrt(2.0))");
//     //jl_value_t *jl_call(jl_function_t *f, jl_value_t **args, int32_t nargs);
//     jl_function_t *func = jl_get_function(jl_base_module, f);
//     jl_value_t *boxed_args = jl_box_float64(args);
//     //jl_value_t *ret = jl_call1(func, argument);
//     jl_value_t *ret = (jl_value_t*) jl_call(func,&boxed_args,1);
//     //jl_value_t *jl_call(jl_function_t *f, jl_value_t **arguments, int 1)
//     //ret = (jl_value_t**)jl_call(jl_function_t *f, jl_value_t **args, int32_t nargs);
//     double ret_unboxed = jl_unbox_float64(ret);
//     jl_atexit_hook(0);
//     return ret_unboxed;
// }

double call_julia_function(const char *f, const boost::python::list& args) //
{
    //jl_init_with_image("/home/raphael/Downloads/julia-1.0.0-linux-x86_64/julia-1.0.0/lib/julia", "sys.so");
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
    def("greet", greet);
    def("call_julia_function", call_julia_function);
}
