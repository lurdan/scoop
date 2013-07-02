# Usage: scoop uninstall <app>
# Summary: Uninstall an app
# Help: e.g. scoop uninstall git
param($app)

. "$psscriptroot\..\lib\core.ps1"
. (resolve ..\lib\manifest.ps1)
. (resolve ..\lib\help.ps1)
. (resolve ..\lib\install.ps1)
. (resolve ..\lib\versions.ps1)

if(!$app) { 'ERROR: <app> missing'; my_usage; exit 1 }

if(!(installed $app)) { abort "$app isn't installed" }

$versions = @(versions $app)
$version = $versions[-1]
"uninstalling $app $version"

$dir = versiondir $app $version
$manifest = installed_manifest $app $version
$install = install_info $app $version
$architecture = $install.architecture

run_uninstaller $manifest $architecture $dir
rm_shims $manifest
rm_user_path $manifest $dir

try { rm -r $dir -ea stop -force }
catch { abort "couldn't remove $(friendly_path $dir): it may be in use" }

# remove older versions
$old = @(versions $app)
foreach($oldver in $old) {
    "removing older version, $oldver"
    $dir = versiondir $app $oldver
    try { rm -r -force -ea stop $dir }
    catch { abort "couldn't remove $(friendly_path $dir): it may be in use" }
}

if(@(versions $app).length -eq 0) {
	rm -r (appdir $app) -ea stop -force
}

success "$app was uninstalled"
exit 0