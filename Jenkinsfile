// This file relates to internal XMOS infrastructure and should be ignored by external users

@Library('xmos_jenkins_shared_library@v0.33.0') _

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
      defaultValue: 'v6.0.0',
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

        sh "git clone -b v1.2.1 git@github.com:xmos/infr_scripts_py"
        sh "git clone -b v2.0.0 git@github.com:xmos/infr_apps"

        dir("${REPO}") {
          checkout scm

          createVenv()
          withVenv {
            sh "pip install -e ${WORKSPACE}/infr_scripts_py"
            sh "pip install -e ${WORKSPACE}/infr_apps"
          }
        }
      }
    }  // Get sandbox

    stage('Library checks') {
      steps {
        withTools(params.TOOLS_VERSION) {
          // creation of tools_released and REPO environment variable are workarounds
          // to allow xcoreLibraryChecks to run without a viewfile-based sandbox
          dir("tools_released") {
            sh "echo ${params.TOOLS_VERSION} > REQUIRED_TOOLS_VERSION"
          }
          xcoreLibraryChecks("${REPO}", false)
        }
      }
    }  // Library checks

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

    stage('Documentation') {
      steps {
        dir("${REPO}") {
          withVenv {
            sh "pip install git+ssh://git@github.com/xmos/xmosdoc@${XMOSDOC_VERSION}"
            sh 'xmosdoc'
            zip zipFile: "${REPO}_docs.zip", archive: true, dir: 'doc/_build'
          } // withVenv
        } // dir
      } // steps
    } // Documentation
  } // stages
  post {
    cleanup {
      xcoreCleanSandbox()
    } // cleanup
  } // post
} // pipeline
