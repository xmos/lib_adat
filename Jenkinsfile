// This file relates to internal XMOS infrastructure and should be ignored by external users

@Library('xmos_jenkins_shared_library@v0.34.0') _

getApproval()

pipeline {
  agent {
    label 'documentation&&linux&&x86_64'
  }
  options {
    buildDiscarder(xmosDiscardBuildSettings())
    skipDefaultCheckout()
  }
  parameters {
    string(
      name: 'TOOLS_VERSION',
      defaultValue: '15.3.0',
      description: 'The XTC tools version'
    )
    string(
      name: 'XMOSDOC_VERSION',
      defaultValue: 'v6.1.0',
      description: 'The xmosdoc version'
    )
  }
  environment {
    REPO = 'lib_adat'
    PIP_VERSION = "24.0"
    PYTHON_VERSION = "3.12.1"
  }
  stages {
    stage('Get sandbox') {
      steps {
        println "Stage running on: ${env.NODE_NAME}"

        dir("${REPO}") {
          checkout scm
          createVenv()
        }
      }
    }  // Get sandbox

    stage('Build examples') {
      steps {
        withTools(params.TOOLS_VERSION) {
          dir("${REPO}/examples") {
            script {
              // Build all apps in the examples directory
              sh "cmake  -B build -G\"Unix Makefiles\" -DDEPS_CLONE_SHALLOW=TRUE"
              sh "xmake -C build"
            } // script
          } // dir
        } //withTools
      } // steps
    }  // Build examples

    stage('Library checks') {
      steps {
        runLibraryChecks("${WORKSPACE}/${REPO}", "v2.0.1")
      } // steps
    }  // Library checks

    stage('Documentation') {
      steps {
        dir("${REPO}") {
          buildDocs()
        } // dir("${REPO}")
      } // steps
    } // stage('Documentation')
  } // stages
  post {
    cleanup {
      xcoreCleanSandbox()
    } // cleanup
  } // post
} // pipeline
