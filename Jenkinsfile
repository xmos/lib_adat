@Library('xmos_jenkins_shared_library@v0.30.0') _

getApproval()

pipeline {
  agent {
    label 'x86_64 && linux'
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
        sh "git clone -b v1.5.0 git@github.com:xmos/infr_apps"

        dir("${REPO}") {
          checkout scm

          createVenv()
          withVenv {
            sh "pip install -e ${WORKSPACE}/infr_scripts_py"
            sh "pip install -e ${WORKSPACE}/infr_apps"
          }
        }

        // Temporarily clone lib_sw_pll until XCommon CMake support is added
        //sh "git clone -b develop git@github.com:xmos/lib_sw_pll"
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
          withEnv(["REPO=${REPO}"]) {
            xcoreLibraryChecks("${REPO}", false)
          }
        }
      }
    }  // Library checks
    stage('Build examples') {
      steps {
        withTools(params.TOOLS_VERSION) {
          dir("${REPO}/examples") {
            script {
              // Build all apps in the examples directory
              def apps = sh(script: "ls -d app_*", returnStdout: true).trim()
              for(String app : apps.split()) {
                // First build using XCommon CMake
                sh "cmake -S ${app} -B ${app}/build -G\"Unix Makefiles\""
                sh "xmake -C ${app}/build"
              }
            }
          }
        }
      }
    }  // Build examples
    stage('Build documentation') {
      steps {
        // Clone infrastructure repositories and setup viewEnv environment as a
        // workaround until this is converted to use xmosdoc
        sh "git clone -b swapps14 git@github.com:xmos/infr_scripts_pl"
        sh "git clone -b feature/update_xdoc_3_3_0 git@github0.xmos.com:xmos-int/xdoc_released"
        withAgentEnv() {
          sh """#!/bin/bash
                cd ${WORKSPACE}/infr_scripts_pl/Build
                source SetupEnv
                cd ${WORKSPACE}
                Build.pl VIEW=apps DOMAINS=xdoc_released
                """
        }
        viewEnv {
          withTools(params.TOOLS_VERSION) {
            dir("lib_adat/lib_adat/doc") {
              sh "xdoc xmospdf"
              archiveArtifacts artifacts: "pdf/*.pdf", fingerprint: true, allowEmptyArchive: false
            }
          }
        }
      }
    }  // Build documentation
  }
  post {
    cleanup {
      xcoreCleanSandbox()
    }
  }
}
