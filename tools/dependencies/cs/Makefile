LIB=../../../lib
CS_TEST=../../../bin-test/cs
CS_LIB=../../../bin/cs

build:
	mkdir -p $(LIB)/cs $(CS_TEST) $(CS_LIB)
	cd Lightstreamer && msbuild Lightstreamer.sln -target:Lightstreamer_Net:Rebuild
	cp -f Lightstreamer/Lightstreamer.Net/bin/Debug/netstandard2.1/Lightstreamer.Net.dll $(LIB)/cs/
	dotnet new console --name TestAll --output $(CS_TEST)
	dotnet add $(CS_TEST)/TestAll.csproj reference Lightstreamer/Lightstreamer.Net/Lightstreamer.Net.csproj
	rm $(CS_TEST)/*.cs
	dotnet new classlib --framework "netstandard2.1" --name Lightstreamer.Client --output $(CS_LIB)
	dotnet add $(CS_LIB)/Lightstreamer.Client.csproj reference Lightstreamer/Lightstreamer.Net/Lightstreamer.Net.csproj
	rm $(CS_LIB)/*.cs

clean:
	rm -rf $(LIB)/cs
	rm -rf $(CS_TEST)
	rm -rf $(CS_LIB)