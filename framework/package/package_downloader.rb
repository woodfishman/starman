module STARMAN
  class PackageDownloader
    extend System::Command
    extend Utils

    def self.run package
      # Check if there is a precompiled binary first.
      if not CommandLine.options[:'local-build'].value
        record = PackageBinary.read_record package
        file_path = "#{ConfigStore.package_root}/#{Storage.tar_name package}"
        if File.exist? file_path
          return :binary if sha_same? file_path, record[package.tag]
          if Storage.uploaded? package
            CLI.report_notice "Downloading precompiled package #{CLI.blue package.name}."
            Storage.download package
            return :binary
          end
        end
      end
      # Package is not compiled before.
      file_path = "#{ConfigStore.package_root}/#{package.filename}"
      if not ( File.exist? file_path and sha_same? file_path, package.sha256 )
        CLI.report_notice "Downloading package #{CLI.blue package.name}."
        curl package.url, ConfigStore.package_root, rename: package.filename
      end
      return :source
    end
  end
end