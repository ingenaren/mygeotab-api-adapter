FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# Set database provider type as environment variable
ENV DatabaseProviderType=PostgreSQL

# Copy solution and project files
COPY *.sln .
COPY */*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p ${file%.*}/ && mv $file ${file%.*}/; done

# Restore dependencies
RUN dotnet restore

# Copy everything else and build
COPY . .
RUN dotnet publish MyGeotabAPIAdapter/MyGeotabAPIAdapter.csproj -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

# Set database provider type in runtime too
ENV DatabaseProviderType=PostgreSQL

COPY --from=build /app/out .

EXPOSE $PORT
ENTRYPOINT ["dotnet", "MyGeotabAPIAdapter.dll"]
