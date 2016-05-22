module STARMAN
  class PackageBinary
    extend System::Command

    class << self
      def read_record package
        file = record_file package
        File.exist?(file) ? YAML.load(File.open(file, 'r').read) : {}
      end

      def write_record package
        file = record_file package
        record = File.exist?(file) ? YAML.load(File.open(file, 'r').read) : {}
        record[package.tag] = Digest::SHA256.hexdigest(File.read("#{ConfigStore.package_root}/#{package.tag}.tgz"))
        CLI.report_notice "Record binary #{CLI.blue package.tag}."
        File.open(file, 'w').write record.to_yaml
      end

      def run package
        if PackageInstaller.installed? package
          CLI.report_notice "Package #{CLI.blue package.name} has been installed."
          return
        end
        FileUtils.mkdir_p package.prefix
        work_in package.prefix do
          decompress "#{ConfigStore.package_root}/#{Storage.tar_name package}"
        end
      end

      protected

      def record_file package
        "#{ENV['STARMAN_ROOT']}/packages/binary/#{package.name}.yml"
      end
    end
  end
end
