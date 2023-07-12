FROM mcr.microsoft.com/dotnet/sdk:7.0-jammy AS build
WORKDIR /source
COPY aspnetapp/*.csproj .
RUN dotnet restore --use-current-runtime
COPY aspnetapp/. .
RUN mkdir /demo
RUN dotnet publish --use-current-runtime --self-contained false --no-restore -o /app
FROM mcr.microsoft.com/dotnet/aspnet:7.0-jammy
WORKDIR /app
COPY --from=build /app .
EXPOSE 80
ENTRYPOINT ["./aspnetapp"]
