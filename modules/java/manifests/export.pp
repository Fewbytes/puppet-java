# http://docs.puppetlabs.com/references/latest/type.html

class java::export(
    $export_path    = true,
    $set_as_default = true,
    $vendor         = "openjdk",
    $version        = "1.7",
    $install_jdk    = true,
    $install_jre    = true,
) {
    
    $java_version = $java::export::version ? {
        "1.6" => "6",
        "1.7" => "7",
    }
    
	Exec{ path => "/usr/bin:/usr/sbin:/sbin:/bin" }

    class oracle {
        
        if $java::export::install_jdk {
            if $java::export::export_path {
                file_line{ "jdk_etc_environment_java_home":
                    path => "/etc/environment",
                    line => "JAVA_HOME=/usr/lib/jvm/java-${java::export::java_version}-oracle/",
                } -> file_line{ "jdk_etc_environment_jre_home":
                    path => "/etc/environment",
                    line => "JRE_HOME=/usr/lib/jvm/java-${java::export::java_version}-oracle/jre/",
                }
            }
        }
        
        if $java::export::install_jre {
            if $java::export::export_path {
                file_line{ "jre_etc_environment_jre_home":
                    path => "/etc/environment",
                    line => "JRE_HOME=/usr/lib/jvm/java-${java::export::java_version}-oracle/jre/",
                }
            }
        }
        
    }
    
    class openjdk {
        
        class openjdk_set_defaults {
            
			define java_update_alternative($path) {
				exec{$title:
					user => root,
					command => "update-alternatives --set ${title} ${path}/$title"
				}	
			}
                
            if $java::export::set_as_default {
                # http://packages.ubuntu.com/precise/amd64/openjdk-6-jdk/filelist
                # http://packages.ubuntu.com/precise/amd64/openjdk-6-jre/filelist
                # http://packages.ubuntu.com/precise/amd64/openjdk-6-jre-headless/filelist
                # http://packages.ubuntu.com/precise/amd64/icedtea-6-plugin/filelist
                
                $path_prefix          = "/usr/lib/jvm/java-${java::export::java_version}-openjdk-${::architecture}"
                
                java_update_alternative { [
                        "appletviewer",
                        #"apt",
                        "extcheck",
                        "idlj",
                        "jar",
                        "jarsigner",
                        "javac",
                        "javadoc",
                        "javah",
                        "javap",
                        "jconsole",
                        "jdb",
                        "jhat",
                        "jinfo",
                        "jmap",
                        "jps",
                        "jrunscript",
                        "jsadebugd",
                        "jstack",
                        "jstat",
                        "jstatd",
                        "native2ascii",
                        "schemagen",
                        "serialver",
                        "wsgen",
                        "wsimport",
                        "xjc",
                        "rmic",
                    ]:
                    path => "${path_prefix}/bin"
                } -> java_update_alternative { [
                        "java",
                        "keytool",
                        "orbd",
                        "pack200",
                        "rmiregistry",
                        "servertool",
                        "tnameserv",
                        "unpack200",
                        "rmid",
                        "policytool",
                    ]:
                    path => "${path_prefix}/jre/bin"
                } -> java_update_alternative {"jexec":
                    path => "${path_prefix}/jre/lib"
				}
				if ! ($java::export::java_version == 7 and $operatingsystem == "Ubuntu" and  versioncmp($operatingsystemrelease, "12.10") < 0) {
					java_update_alternative { "javaws":	
						path => "${path_prefix}/jre/lib"
					}
                    java_update_alternative {"libnpjp2":
						path => "${path_prefix}/jre/lib/${::architecture}/IcedTeaPlugin.so",
					}
				}
            }
            
        }
        
        if $java::export::install_jdk {
            if $java::export::export_path {
                file_line{ "jdk_etc_environment_java_home":
                    path => "/etc/environment",
                    line => "JAVA_HOME=/usr/lib/jvm/java-${java::export::java_version}-openjdk-${::architecture}/",
                } -> file_line{ "jdk_etc_environment_jre_home":
                    path => "/etc/environment",
                    line => "JRE_HOME=/usr/lib/jvm/java-${java::export::java_version}-openjdk-${::architecture}/jre/",
                }
            }
            
            include "openjdk_set_defaults"
        }
        
        if $java::export::install_jre {
            if $java::export::export_path {
                file_line{ "jre_etc_environment_jre_home":
                    path => "/etc/environment",
                    line => "JRE_HOME=/usr/lib/jvm/java-${java::export::java_version}-openjdk-${::architecture}/jre/",
                }
            }
            
            include "openjdk_set_defaults"
        }
        
    }
    
    if $::osfamily == "Debian" {
        class { $java::export::vendor: }
    }
    
}
