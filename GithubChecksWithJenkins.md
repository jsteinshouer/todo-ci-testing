
## Github Checks / Jenkins Integration

Jenkins has a plugin to integration a Jenkins build process and publish the results to the Github Checks API. This allows you do get feedback on if a pull request breaks any automated tests prior to merging a pull request.

Here are the basic steps to setup it.

### Install the Github Checks and Junit plugins to Jenkins
    
[GitHub Checks](https://plugins.jenkins.io/github-checks/#documentation)
[JUnit](https://plugins.jenkins.io/junit/)

### Setup Authentication Credentials

In order to authenticate Jenkins with the Github API you will need to setup a Github App and install it to the Orgs and Accounts where it will be used. I followed this guide to set it up.

[Github App Authentication Guide](https://github.com/jenkinsci/github-branch-source-plugin/blob/master/docs/github-app.adoc)

### Jenkins Build Configuration

Create your Jenkins build configuration file i.e. `Jenkinsfile`. Here is an example.

```
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                bat 'box install'
                bat 'box server start name="todo-ci-build${BUILD_NUMBER}" cfengine=lucee@5 rewritesEnable=true saveSettings=true jvmArgs="-Dlucee-extensions=465E1E35-2425-4F4E-8B3FAB638BD7280A" trayEnable=false openbrowser=false --verbose'
            }
        }
        stage('Test') {
            steps {
                script {
                    env.SERVER_PORT = bat(script: '@box server status name="todo-ci-build${BUILD_NUMBER}" property="port"', returnStdout: true).trim()
                }
                bat 'box testbox run runner=http://127.0.0.1:${SERVER_PORT}/tests/runner.cfm outputFile=test-results/junit.xml reporter=junit'
                junit 'test-results/junit.xml'
            }
        }
    }
    post {
        always {
            bat 'box server stop name="todo-ci-build${BUILD_NUMBER}"'
            bat 'box server forget name="todo-ci-build${BUILD_NUMBER}" --force'
            dir('test-results') {
                deleteDir()
            }
        }
    }
}
```

In the Test stage it is running the tests with Testbox and output the results in JUnit XML format. The the JUnit plugin will use those results and keep track of the results for you in Jenkins. It will also publish those results to Github in the pull request.

### Configure a multibranch pipeline in Jenkins

```
Branch Source: Github

Credentials: Use the Github App credentials setup using the [Github App Authentication Guide](https://github.com/jenkinsci/github-branch-source-plugin/blob/master/docs/github-app.adoc).

Repository URL: https://git.seniormarketsales.com/jason/todo-ci-test.git

Behaviors: Discover Branches (Only branches filed as PR)

Build Configuration: Jenkinsfile
Scan Repository Triggers: 2 Min (Could possibly use Github Webhooks for this)
```
