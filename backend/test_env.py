from pydantic_settings import BaseSettings, SettingsConfigDict

class S(BaseSettings):
    MONGODB_URI: str
    model_config = SettingsConfigDict(env_file='.env', env_file_encoding='utf-8')

print(S().model_dump())
