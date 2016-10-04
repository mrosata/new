## "New"
####   - Simple, Configurable, Hierarchical, Shareable... Blueprints. 

> October 04, 2016
> This project and README are in the works. I wanted to get a synopsis up though.

##### Introduction
Everybody creates files, developers create a lot of them and usually with commonalities such as an `index.html` file which follows a common HTML5 boilerplate, maybe a component for a framework or a `.gitignore` template. Bottom line, we boilerplate like whoa.

##### What the "New Blueprint" or simply "New" project would accomplish:

A configuration language which allows developers to generate predefined blueprints or to write custom blueprints for projects and also system-wide templates.

##### What makes this special?

Blueprints are hierarchal which means they could be defined anywhere in a filesystem. This will be made clear below. Some MVC frameworks ship with CLI tools to spin up basic templates and may even offer
customization, but that customisation more than likely has to be re-done with each project. Blueprints being heirarchal means a global configuration file could ensure that every single project you write using that framework could benefit from a one time change. Additionally, it would be trivial to drop a "new" config file with a one off template definition that any developer forking or cloning your project could benefit from.


###### EXAMPLE 1:

Maybe I have a template that I've used to start my Ember Components and I'd like to use to start any new component with. It looks like:

```js
import Ember from 'ember';

const { Component } = Ember;

export default Component.extend({
  actions: {}
});
```

No matter what Ember project I'm working on, I would want to use this
template without doing any configuration and I want my team to be able
to do the same. We'll achieve this by sharing a single configuration
file and from the command line we simply run:

```sh
$ new component pooh-bear
```
and a file with the template above would be written to
`./app/components/pooh-bear.js`.
Additionally we would want a test file to be generated as well at
`./tests/integration/pooh-bear-test.js`

This will be easily achievable through the
blueprinting language. Some important additional facts to note about
running the `new` command are:
A). environment aware - No matter what directory I'm currently in, I
need this component to be in the projects app directory. Some
blueprints will just write a file to whatever directory the user is
in, but others should have the ability to write themselves relative to
the configuration file.
B). A global configuration in the users home directory such as
`~/.blueprint` will have the ability to declare itself "absolute",
meaning that configuration files in project directories can't define
that same blueprint. (Well they can but it won't do anything). By
default, the nearest config file when the command is run will be given
priority unless the global config declared itself absolute.

*** when the configuration file is stored globally but the blueprint
is to be written nested from the root of a project, the config must
be able to figure out for itself where to put the file and to prompt
the user with some warning/error if it can't figure that out.***

Imagine we are in the directory:
`/home/michael/projects/hundred-acres/`
We run the command:
`new component pooh-bear`
The program will:
1) Check home directory for a `.blueprint` configuration file
  If it exists check for "component" blueprint and whether it is
  "locked", meaning that there is no reason to search for a closer
  blueprint to the project because the 
1) Find *nearest* configuration file.
  Is there a `.blueprint` file in
    `/home/michael/projects/hundred-acres` ?
       **No..**
  Is there a `.blueprint` file in
    `/home/michael/projects` ?
       **No..**
  Is there a `.blueprint` file in
    `/home/michael` ?
      **YES!**
2) Read configuration file for instructions
  Is there a "component" blueprint?
    **YES!**
    The program then reads the blue print rules. 


If no, then continue working up
  the directories until the next blueprint file is found


### A Couple Conventions
Let's make this super simple... instead of creating another "thing"
for developers to use, we should try to compose the project from
things that we already use on a daily basis.

1. Naming Config files use the .blueprint or .blueprint-xxxx syntax.
  below is an untested RE to hunt files where $1 is a specific blueprint
  /^\.blueprint(-[a-zA-Z\-]+)?$/

2. Configuration files should be written in either JSON or YAML



### General Idea
The following configuration would define 5 templates, however 1 of those templates
actually is an instruction to create multiple templates from 3 of the defined
templates, the `do` property would tell the program to create all the templates
listed. The `defined` property would tell the program where the template was 
defined either locally or on the internet somewhere.
```json
{
  "component": {
    "absolute": 1,
    "do": ["ember-component-js", "ember-component-hbs", "ember-component-tests"]
   },
   "ember-component-js": {
     "defined": "https://github.com/mrosata/templates/component.js",
  },
   "ember-component-hbs": {
     "defined": "./templates/component.hbs",
  },
  "ember-component-tests": {
    "defined": "/home/michael/projects/blueprints/component.js"
  },
  "html5": {
    "defined": "./templates/html5.html"
  }
}
```

###### EXAMPLE 2: Generic naming
If a developer had many static templates and didn't want to define them all
through the JSON config file then it would be easy to just use the special
property `*` which points to a folder containing files with boilerplates which
can be used by name

```json
{
  "*": "/home/michael/blueprints/generic"
}
```

If the folder `/home/michael/blueprints/generic` held the files `index.html`, `basic.py`
and `complex` then the commands

```bash
; Create a file called `pottery.py` using the `basic.py` generic template.
new basic.py pottery.py
```

Notice the file `complex` didn't have an extension, it could have any extension
that you choose, so while I wouldn't recommend not using extensions, you could use
that to do
```bash
; Create a file called `pottery.py` using the `complex` generic template.
new complex pottery.py
```

But.. then if you defined a template in your config called "complex" you wouldn't be
able to use the generic template because specificity matters. The program only looks
in the generics folder `"*"` after not finding a template explicitly listed.
