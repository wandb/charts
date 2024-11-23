{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
helm.sh/chart: {{ include "app.chart" . }}
{{ include "app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
wandb.com/app-name: {{ include "app.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}{{ .suffix }}
app.kubernetes.io/instance: {{ .Release.Name }}{{ .suffix }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Returns the extraEnv keys and values to inject into containers.

Global values will override any chart-specific values.
*/}}
{{- define "app.extraEnv" -}}
{{- $allExtraEnv := merge (default (dict) .local.extraEnv) .global.extraEnv -}}
{{- range $key, $value := $allExtraEnv }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{/*
Returns a list of _common_ labels to be shared across all
app deployments and other shared objects.
*/}}
{{- define "app.commonLabels" -}}
{{- $commonLabels := default (dict) .Values.common.labels -}}
{{- if $commonLabels }}
{{-   range $key, $value := $commonLabels }}
{{ $key }}: {{ $value | quote }}
{{-   end }}
{{- end -}}
{{- end -}}

{{/*
Returns a list of _pod_ labels to be shared across all
app deployments.
*/}}
{{- define "app.podLabels" -}}
{{- range $key, $value := .Values.pod.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end -}}

{{- define "app.redis" -}}
{{- $cs := include "wandb.redis.connectionString" . }}
{{- $ca := include "wandb.redis.caCert" . }}
{{- if $ca }}
{{- printf "%s?tls=true&caCertPath=/etc/ssl/certs/redis_ca.pem&ttlInSeconds=604800" $cs -}}
{{- else }}
{{- print $cs -}}
{{- end }}
{{- end }}

{{- define "app.bucket" -}}
{{- $bucketValues := .Values.global.defaultBucket }}
{{- if .Values.global.bucket.provider }}
{{- $bucketValues = .Values.global.bucket }}
{{- end }}
{{- $bucket := "" -}} 
{{- if eq $bucketValues.provider "az" -}}
{{- $bucket = printf "az://%s/%s" $bucketValues.name (default "" $bucketValues.path) -}}
{{- end -}}
{{- if eq $bucketValues.provider "gcs" -}}
{{- $bucket = printf "gs://%s/%s" $bucketValues.name (default "" $bucketValues.path) -}}
{{- end -}}
{{- if eq $bucketValues.provider "s3" -}}
{{- if and $bucketValues.accessKey $bucketValues.secretKey -}}
{{- $bucket = printf "s3://%s:%s@%s/%s" $bucketValues.accessKey $bucketValues.secretKey $bucketValues.name (default "" $bucketValues.path) -}}
{{- else -}}
{{- $bucket = printf "s3://%s/%s" $bucketValues.name (default "" $bucketValues.path) -}}
{{- end -}}
{{- end -}}
{{- trimSuffix "/" $bucket -}}
{{- end -}}

{{- define "app.internalJWTMap" -}}
'{
{{- range $value := .Values.internalJWTMap -}}
{{- printf "%q: %q" $value.subject $value.issuer }},
{{- end -}}
}'
{{- end -}}

{{- define "app.runUpdateShadowTopic" }}
{{- if .Values.global.pubSub.enabled }}
pubsub://{{ .Values.global.pubSub.project }}/{{ .Values.global.pubSub.runUpdateShadowTopic }}
{{- else }}
kafka://$(KAFKA_CLIENT_USER):$(KAFKA_CLIENT_PASSWORD)@$(KAFKA_BROKER_HOST):$(KAFKA_BROKER_PORT)/$(KAFKA_TOPIC_RUN_UPDATE_SHADOW_QUEUE)?producer_batch_bytes=1048576&num_partitions=$(KAFKA_RUN_UPDATE_SHADOW_QUEUE_NUM_PARTITIONS)&replication_factor=3
{{- end -}}
{{- end -}}

{{- define "app.historyStore" -}}
{{- $historyStore := printf "http://%s-parquet" .Release.Name -}}
{{- if .Values.global.bigTable.enabled }}
{{- $historyStore = printf "%s,bigtablev3://%s/%s,bigtablev2://%s/%s" $historyStore .Values.global.bigTable.project .Values.global.bigTable.instance .Values.global.bigTable.project .Values.global.bigTable.instance -}}
{{- else -}}
{{- $historyStore = printf "%s,mysql://$(MYSQL_USER):$(MYSQL_PASSWORD)@$(MYSQL_HOST):$(MYSQL_PORT)/$(MYSQL_DATABASE)?tls=preferred" $historyStore }}
{{- end -}}
{{- $historyStore -}}
{{- end -}}

{{- define "app.liveHistoryStore" -}}
{{- if .Values.global.bigTable.enabled }}
{{- printf "bigtablev3://%s/%s,bigtablev2://%s/%s" .Values.global.bigTable.project .Values.global.bigTable.instance .Values.global.bigTable.project .Values.global.bigTable.instance -}}
{{- end -}}
mysql://$(MYSQL_USER):$(MYSQL_PASSWORD)@$(MYSQL_HOST):$(MYSQL_PORT)/$(MYSQL_DATABASE)?tls=preferred
{{- end -}}