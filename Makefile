
COMPILER = protoc

SWIFT_OPTS = --swift_out
SWIFT_DIR = ios/Runner/

JAVA_OPTS = --java_out
JAVA_DIR = android/app/src/main/java

DART_OPTS = --dart_out
DART_DIR = lib/protobuf

CUR_DIR = $(shell pwd)
INCLUDED = $(CUR_DIR)/protobuf/

PROTO_FILES = $(CUR_DIR)/protobuf/*.proto
# include well known as dart still not convincing to include well-known into library
# See https://github.com/protocolbuffers/protobuf/issues/5678
WELL_KNOWN_TYPES = $(CUR_DIR)/protobuf/google/protobuf/any.proto

genproto:
	@echo "Generate Swift from Proto files ..."
	$(COMPILER) $(SWIFT_OPTS)=$(SWIFT_DIR) -I$(INCLUDED) $(PROTO_FILES)

	@echo "Generate Java from Proto files ..."
	$(COMPILER) $(JAVA_OPTS)=lite:$(JAVA_DIR) -I$(INCLUDED) $(PROTO_FILES)

	@echo "Generate Dart from Proto files ...."
	$(COMPILER) $(DART_OPTS)=$(DART_DIR) -I$(INCLUDED) $(PROTO_FILES)