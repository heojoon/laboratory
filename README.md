# J00n2's Laboratory

# Infrastructure as Code. 

## 1. Requrement.
 - Langage : python 3.x upper
 - Packages : awscli , fabric , boto3 , terraform


## 2. Installation for MacOS


### 2.1. Install brew , python3

- Install homebrew
~~~
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"   
~~~

- Install python3
~~~
brew install python3
~~~


### 2.2. Install vritualenv and configuration. 

~~~
$ pip3 install virtualenv

# Create python project environment.
$ mkdir ~/pyenv
$ cd ~/prenv
$ virtualenv -p python3 py3
~~~

### 2.3. Activation virtualenv

~~~
source ~/pyenv/py3/bin/activate
~~~

### 2.4. Install Helpful packages 
~~~
pip install awscli fabric boto3
brew install terraform
~~~


Ref
https://brew.sh/index_ko.html 
http://knot.tistory.com/102 
