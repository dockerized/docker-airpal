FROM java:8

# Airpal
ENV AIRPAL_COMMIT e3e65283d66d866c3321fd921e02428c6aed1747
ENV AIRPAL_HOME /opt/airpal
WORKDIR $AIRPAL_HOME

RUN set -x \
  && apt-get update && apt-get install -y make g++ \
  && export BUILD_DIR=$(mktemp -d) && cd "${BUILD_DIR}" \
  && git clone https://github.com/airbnb/airpal \
  && cd airpal \
  && ./gradlew clean shadowJar \
  && mkdir -p ${AIRPAL_HOME} \
  && cp build/libs/airpal-*-all.jar $AIRPAL_HOME \
  && cd "${HOME}" && rm -rf .npm .gradle .node-gyp \
  && rm -rf "${BUILD_DIR}" \
  && apt-get purge --auto-remove -y make g++ \
  && apt-get clean

ADD config/reference.h2.yml $AIRPAL_HOME/reference.yml

RUN set -x \
  && java -Duser.timezone=UTC -cp ${AIRPAL_HOME}/airpal-*-all.jar \
  com.airbnb.airpal.AirpalApplication db migrate ${AIRPAL_HOME}/reference.yml

EXPOSE 8081 8082
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
