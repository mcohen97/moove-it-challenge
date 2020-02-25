FROM ruby:2.6.4

RUN mkdir /application
WORKDIR /application
COPY /server /application
RUN gem install bundler -v 2.0.2 && bundle install 
EXPOSE 5000

CMD ruby lib/my_memcached.rb