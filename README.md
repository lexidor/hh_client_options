# Lexidor/hh_client_options

This project attempts to push the Hack/hhvm ecosystem forward by tracking the support for the stricter hh_client options. Hack is by default decently strict, but projects may decide to restrict themselves to a stricter subset of Hack, in exchange for better typing. However, when a dependency (first or third party) does not meet these stricter requirements, the typechecker errors on those dependencies. This project tries to find the set of options that all\* oss project adhere to, as a common baseline. I will also be making contributions to those oss projects, to try and allow more options to be a baseline.

### Adding your own projects

If you believe that the stricter hh_client options are providing value, you may decide to add your project (or a project you use) to the composer.json file. That way, I'll be warned about incompatibilities with these projects. I might even chip in to make your project meet the requirements for these options.

### How to get started

At the root of this project, you'll find the `.hhconfig` file. The options that are set in there have been found to work for all the listed dependencies. You can copy these options as a base for you own project, removing those that you don't care about, without fear that a library will not support these options.

For the full list of checked libraries, see composer.json.

#### Footnote

This project intentionally depends on the bleeding edge. If you are not able/willing to run hhvm-latest and/or some projects `dev-master`, you might find that some options don't work for you yet.

#### Experimental

hhast-lint support

In order to lint, you will need to navigate into the project and lint with its hhast-lint.json file. 
