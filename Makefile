build:
	swift build -c release
	cp .build/x86_64-apple-macosx/release/swift-gen ./
	zip -r swift-gen swift-gen
	rm -f swift-gen

clean:
	rm -f swift-gen
	rm -r -f .build