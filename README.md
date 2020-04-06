# URL shortening service

- Used secure random to generate random alphanumeric string of 8 chars.
- Mapped url to unique code
- If url already exists, return the same unique code
- Implemented a user profile, with signup and login.
- User can create and track their urls
- User can also mark a url expired, which will be deleted from db.
- Login returns JWT token with expiry, access and refresh
- On expiry of access token, refresh token can be used to get fresh set of access and refresh tokens
- Invalidating both the tokens on logout