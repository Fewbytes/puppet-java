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
            
            if $java::export::set_as_default {
                # http://packages.ubuntu.com/precise/amd64/openjdk-6-jdk/filelist
                # http://packages.ubuntu.com/precise/amd64/openjdk-6-jre/filelist
                # http://packages.ubuntu.com/precise/amd64/openjdk-6-jre-headless/filelist
                # http://packages.ubuntu.com/precise/amd64/icedtea-6-plugin/filelist
                
                $path_prefix          = "/usr/lib/jvm/java-${java::export::java_version}-openjdk-${::architecture}"
                $jdk_command_template = "update-alternatives --set ${name} ${path_prefix}/bin/${name}"
                $jre_command_template = "update-alternatives --set ${name} ${path_prefix}/jre/bin/${name}"
                $lib_command_template = "update-alternatives --set ${name} ${path_prefix}/jre/lib/${name}"
                
                Exec { user => root, }
                
                exec { "jdk_defaults":
                    name    => [
                        "appletviewer",
                        "apt",
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
                        "rmid",
                        "schemagen",
                        "serialver",
                        "wsgen",
                        "wsimport",
                        "xjc",
                        "policytool",
                        "rmic",
                    ],
                    command => $jdk_command_template,
                } -> exec { "jre_defaults":
                    name    => [
                        "java",
                        "keytool",
                        "orbd",
                        "pack200",
                        "rmiregistry",
                        "servertool",
                        "tnameserv",
                        "unpack200",
                        "javaws",
                    ],
                    command => $jre_command_template,
                } -> exec { "lib_defaults":
                    name    => [
                        "jexec",
                    ],
                    command => $lib_command_template,
                } -> exec { "browser_defaults":
                    name    => [
                        "libnpjp2",
                    ],
                    command => "update-alternatives --set libnpjp2.so  ${path_prefix}/jre/lib/${::architecture}/IcedTeaPlugin.so",
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
