from conans import ConanFile, CMake


class MyprojectConan(ConanFile):
    name = 'myproject'
    version = '0.0.1'
    license = '<Put the package license here>'
    url = '<Package recipe repository url here, for issues about the package>'
    description = '<Description of Myproject here>'
    settings = 'os', 'compiler', 'build_type', 'arch'
    options = {'shared': [True, False]}
    default_options = 'shared=False'
    exports_sources = 'src/*'

    # warning: this must be a tuple
    # (a list won't work for some obscure reason)
    generators = (
        'cmake',
        'compiler_args',
        'txt',
    )

    # warning: this must be a tuple
    # (a list won't work for some obscure reason)
    requires = (
        'clara/1.1.1@bincrafters/stable',
        'spdlog/0.16.3@bincrafters/stable',
        'protobuf/3.5.2@bincrafters/stable',
        'gtest/1.8.0@bincrafters/stable',
        'Qt/5.11@bincrafters/stable',
    )

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
        cmake.install()
