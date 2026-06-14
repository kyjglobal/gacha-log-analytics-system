import re
import sys
from pathlib import Path


ALLOWED_TYPES = (
    "feat",
    "fix",
    "refactor",
    "style",
    "docs",
    "test",
    "chore",
)

ALLOWED_SCOPES = (
    "auth",
    "gacha",
    "inventory",
    "statistics",
    "community",
    "admin",
    "frontend",
    "backend",
    "api",
    "database",
    "user",
    "docs",
    "docker",
    "erd",
    "project",
)

PATTERN = re.compile(
    rf"^({'|'.join(ALLOWED_TYPES)})"
    rf"\(({'|'.join(ALLOWED_SCOPES)})\): "
    r"(?=.*[가-힣]).+$"
)


def read_subject(arguments: list[str]) -> str:
    if len(arguments) == 3 and arguments[1] == "--message":
        return arguments[2].strip()

    if len(arguments) == 2:
        message_path = Path(arguments[1])
        return message_path.read_text(encoding="utf-8").splitlines()[0].strip()

    raise ValueError(
        "사용법: validate_commit_msg.py <commit-msg-file> "
        "또는 validate_commit_msg.py --message <subject>"
    )


def main() -> int:
    try:
        subject = read_subject(sys.argv)
    except (OSError, ValueError) as error:
        print(error)
        return 2

    if subject.startswith(("Merge ", "Revert ")):
        return 0

    if PATTERN.fullmatch(subject):
        return 0

    print("커밋 메시지가 프로젝트 규칙과 일치하지 않습니다.")
    print("형식: type(scope): 한국어 설명")
    print("예시: feat(auth): JWT 로그인 기능 구현")
    print(f"입력: {subject}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
