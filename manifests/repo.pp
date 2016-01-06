# PRIVATE CLASS: do not use directly
class mongodb::repo (
  $ensure  = $mongodb::params::ensure,
) inherits mongodb::params {
  case $::osfamily {
    'RedHat', 'Linux': {
      if $mongodb::globals::use_enterprise_repo == true {
        $location = 'https://repo.mongodb.com/yum/redhat/$releasever/mongodb-enterprise/stable/$basearch/'
        $description = 'MongoDB Enterprise Repository'
      }
      else {
        $location = $::architecture ? {
          'x86_64' => 'http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/',
          'i686'   => 'http://downloads-distro.mongodb.org/repo/redhat/os/i686/',
          'i386'   => 'http://downloads-distro.mongodb.org/repo/redhat/os/i686/',
          default  => undef
        }
        $description = 'MongoDB/10gen Repository'
      }
      class { '::mongodb::repo::yum': }
    }

    'Debian': {
      if(versioncmp($::mongodb::globals::version, '3.0.0') >= 0 or $::mongodb::globals::version == undef) {
        $location = $::operatingsystem ? {
          'Debian' => 'http://repo.mongodb.org/apt/debian',
          'Ubuntu' => 'http://repo.mongodb.org/apt/ubuntu',
          default  => undef,
        }
        $aptkey = '42F3E95A2C4F08279C4960ADD68FA50FEA312927'
        if versioncmp($::mongodb::globals::version, '3.1.0') < 0 {
          $release = "${::lsbdistcodename}/mongodb-org/3.0"
        }
        elsif versioncmp($::mongodb::globals::version, '3.2.0') < 0 {
          $release = "${::lsbdistcodename}/mongodb-org/3.1"
        }
        elsif versioncmp($::mongodb::globals::version, '3.3.0') < 0 {
          $release = "${::lsbdistcodename}/mongodb-org/3.2"
        }
        else {
          $release = "${::lsbdistcodename}/mongodb-org/stable"
        }
        $repos = 'multiverse'
      }
      else {
        $location = $::operatingsystem ? {
          'Debian' => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit',
          'Ubuntu' => 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart',
          default  => undef
        }
        $aptkey = '492EAFE8CD016A07919F1D2B9ECBEC467F0CEB10'
        $release = 'dist'
        $repos = '10gen'
      }
      class { '::mongodb::repo::apt': }
    }

    default: {
      if($ensure == 'present' or $ensure == true) {
        fail("Unsupported managed repository for osfamily: ${::osfamily}, operatingsystem: ${::operatingsystem}, module ${module_name} currently only supports managing repos for osfamily RedHat, Debian and Ubuntu")
      }
    }

  }

}
