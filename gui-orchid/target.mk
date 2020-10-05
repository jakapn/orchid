# Orchid - WebRTC P2P VPN Market (on Ethereum)
# Copyright (C) 2017-2019  The Orchid Authors

# GNU Affero General Public License, Version 3 {{{ */
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# }}}


shared/gui/in_app_purchase/pubspec.yaml: shared/gui/plugins/packages/in_app_purchase/pubspec.yaml shared/gui/target.mk
	rsync -a --delete $(dir $<) $(dir $@)
	rsync -a --delete $(dir $@){ios,macos}/
	sed -ie 's@Flutter/Flutter@FlutterMacOS/FlutterMacOS@g' $(dir $@)macos/Classes/*.[hm]
	sed -ie 's/Platform\.isIOS/Platform.isIOS || Platform.isMacOS/g' $(dir $@)lib/src/in_app_purchase/in_app_purchase_connection.dart
	sed -ie "s/'Flutter'/'FlutterMacOS'/g; s/:ios, '[^']*'/:osx, '10.11'/g; s/, 'VALID_ARCHS' => '[^']*'//g" $(dir $@)macos/*.podspec
	sed -ie 'x;/./{G;};x;/^ *ios:/h;/^$$/{x;s/ios:/macos:/g;}' $(dir $@)pubspec.yaml
	#git apply --directory=$(dir $@)ios ../app-shared/iap-ios-macos.patch
	#git apply --directory=$(dir $@)macos ../app-shared/iap-ios-macos.patch
	cd in_app_purchase/ios && git apply --verbose ../../../app-shared/iap-ios-macos.patch
	cd in_app_purchase/macos && git apply --verbose ../../../app-shared/iap-ios-macos.patch
	@touch $@
forks += shared/gui/in_app_purchase/pubspec.yaml
