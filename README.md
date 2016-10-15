## "New"
####   - Simple, configurable and shareable... Blueprints. 

> October 13, 2016

#### Introduction
We all create boilerplate code. There are tons of tools that help us to do this. Most of them are either designed for a
specific project or framework or large scaffolding apps for generating entire projects. "New" or "Blueprints" is something
of a hybrid, it allows you to create boilerplate code for a wide array of projects. The boilerplate can be a single file,
or it can be a chain of files. One of the great aspects about new is that it is meant to be both simple and flexible.

If you wanted to create a new blueprint called "component" then from where you were when you decided to create the
blueprint, simply run:
```bash
  new new component  
```

This creates an empty "new" boilerplate folder, template, and configuration file. The folder (saved in the global "new" templates
folder) is called `component` because that's what we named it using the previous command `new new component`. The configuration file
is named `.new-conf`, "new" configuration files are always named `.new-conf`. The template file is named `template` and this can be
changed to any name you want (it can even point to boilerplate files in other locations).


So we now have nestled away somewhere on our computer a folder like:
```txt
   ..
     component
       .new-conf
       template
```
 
Let's open up the `.new-conf` file. If you just installed "new" then it should be located at `boilerplates/component/.new-conf` from
the directory you installed in. You could also run `new -f` to see "folder locations" or to simply edit a config file directly
from your favorite set `EDITOR`, for any "new" boilerplate just running `new -e component` and that will open up the configuration
file for the "component" boilerplate. To edit the current template run `new -e component template`

```bash
template=template
newpath=
after=
```

If the configuration looks like a bash script, ding ding ding! We told you that "new" is simple. The variable for `template`
points "new" to the file to use as the boilerplate. The variable `newpath` is useful for working with project. Imagine my
components go into the folder named 'app/components', then I wouldn't want to cd into that directory from the root of all
my projects, so we could simply set the `newpath=app/components`.

The `after=` variable is special, this says that after regenerating this boilerplate to then run another boilerplate. We'll
get to that and why it is so powerful later. For now, let's destroy this boilerplate.

```bash
# Use new list to see all your installed boilerplates
$ new list
  Found 1 templates:
      component

# Now let's destroy that boilerplate
$ new destroy component

# Run new list again to see that it is gone
$ new list
  Found 0 templates
```

Alright. So now we know how to make an empty boilerplate and how to destroy it. Let's actually do something useful with "new", we'll create a blueprint 
which when triggered will generate multiple boilerplate files, in seperate 
directory trees. More than likely when you create certain types of fi  




### Will-Change
>-  `$NEW_TEMPLATES_DIR` will be a "default" value which shall easily   
be overwritten by any number of configuration files located in  
the users `$HOME_DIR` or project folders.
>-  Somehow variables will be available for use inside templates. This
feature requires some thought since "new"/blueprints must work for
all file types, so it must be careful about how it chooses to identify
variables intented to be templated and boilerplate with similar syntax 
that is just meant to be part of the template. (perhaps the variables
will be explict mappings between search and replace values)
>-  There will be a restore. The backup is already done.        
