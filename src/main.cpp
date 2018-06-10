#include <cstdlib>
#include <iostream>

#include "clara.hpp"

int main(int argc, char **argv) {
    int width = 0;
    bool show_help = false;

    auto cli = clara::Opt(width, "width")["-w"]["--width"]("How wide should it be?") |
               clara::Help(show_help);

    auto result = cli.parse(clara::Args(argc, argv));

    // A call for help always takes precedence
    if (show_help) {
        std::cerr << "This is supposed to be helpful..." << std::endl;
        std::exit(0);
    }

    if (!result) {
        std::cerr << "Error in command line: " << result.errorMessage() << std::endl;
        std::exit(1);
    }
}