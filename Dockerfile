FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG TARGETARCH
WORKDIR /src

COPY ./Phonograph.sln .
COPY Phonograph/Phonograph.csproj ./Phonograph/Phonograph.csproj

RUN dotnet restore -a $TARGETARCH Phonograph

# Build
COPY . .
RUN dotnet publish -a $TARGETARCH --no-restore -c Debug Phonograph

RUN mkdir /app
RUN cp -r \
		Phonograph/bin/Debug/net*/*/publish/** \
		/app

FROM mcr.microsoft.com/dotnet/runtime:8.0

ARG TOKEN
ARG LAVALINK_HOST
ARG LAVALINK_PORT
ARG LAVALINK_PASSWORD

ENV TOKEN=${TOKEN}
ENV LAVALINK_HOST=${LAVALINK_HOST}
ENV LAVALINK_PORT=${LAVALINK_PORT}
ENV LAVALINK_PASSWORD=${LAVALINK_PASSWORD}

# Needed when csproj is .NET 7
ENV DOTNET_ROLL_FORWARD=Major
ENV DOTNET_ROLL_FORWARD_PRE_RELEASE=1

WORKDIR /app
COPY --from=build /app .

CMD ./Phonograph ${TOKEN} ${LAVALINK_HOST}:${LAVALINK_PORT} ${LAVALINK_PASSWORD}
