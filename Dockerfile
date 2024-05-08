# Dockerfile
FROM ruby:3.3

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 8080
CMD ["bundle", "exec", "puma", "-p", "8080"]
