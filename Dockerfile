# Get Base Image (Full .NET Core SDK)
# Getting .NET SDK from microsfot so the Docker engine can compile the app
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env

# speficying a dedicated work dir
WORKDIR /app


# Copy csproj and restore
# copy the .csproj file fomr the PC to the workir /app
COPY *.csproj ./
# donet restore helps us resolve any project dependencies using the .csproj file and retrievieng needed dependencies. 
RUN dotnet restore

# Copy everything else and build
COPY . ./
#  We run the dotnet publish command, specifying that it is a Release build, 
# (-c Release), as well as specifying a folder, (out), to contain the app build dll and any support files & libraries.
RUN dotnet publish -c Release -o out

# Generate runtime image
# To keep our image “lean” we retrieve only the  aspnet run time image, 
# (as opposed t the full SDK image we used for building), as this is all our app requires to “run”.
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
# re-specify workdir (to make sure JustInCase)
WORKDIR /app
# expose port 
EXPOSE 80
# Copy the relevant files from both the dependency resolution step, (build-env), and build step, (/app/out), 
#  to our working directory /app
COPY --from=build-env /app/out .
# Set the entry point for the app, (i.e. what should start), in this case it’s our published .dll using “dotnet”.
ENTRYPOINT ["dotnet", "SampleAppForDocker.dll"]