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