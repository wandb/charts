{{/*
Expand the name of the chart.
*/}}
{{- define "clickhouse-keeper.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "clickhouse-keeper.fullname" -}}
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
{{- define "clickhouse-keeper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Returns a list of _common_ labels to be shared across all
app deployments and other shared objects.
*/}}
{{- define "clickhouse-keeper.commonLabels" -}}
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
{{- define "clickhouse-keeper.podLabels" -}}
{{- range $key, $value := .Values.pod.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "clickhouse-keeper.labels" -}}
helm.sh/chart: {{ include "clickhouse-keeper.chart" . }}
{{ include "clickhouse-keeper.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
wandb.com/app-name: {{ include "clickhouse-keeper.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Replica count
*/}}
{{- define "clickhouse-keeper.replicaCount" -}}
{{- default 1 .Values.replicaCount }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "clickhouse-keeper.selectorLabels" -}}
app.kubernetes.io/name: {{ include "clickhouse-keeper.name" . }}{{ .suffix }}
app.kubernetes.io/instance: {{ .Release.Name }}{{ .suffix }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "clickhouse-keeper.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "clickhouse-keeper.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* 
Create container ports to use
*/}}
{{- define "clickhouse-keeper.containerPorts" -}}
{{- range .Values.container.kepper.ports }}
- name: {{ .name }}
  targetPort: {{ .targetPort }}
  port: {{ .port }}
  protocol: {{ .protocol }}
{{- end }}
{{- end }}

{{- define "clickhouse-keeper.raftPort" -}}
{{- range .Values.container.ports }}
  {{- if eq .name "raft" }}
    {{ .port }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "clickhouse-keeper.raftServer" -}}
{{- range $i, $e := until (int .Values.replicaCount) }}
<server>
  <id>{{ $i }}</id>
  <hostname>ch-keeper-{{ $i }}.{{ include "clickhouse-keeper.fullname" $ }}-headless.svc.cluster.local</hostname>
  <port>{{ include "clickhouse-keeper.raftPort" $ }}</port>
</server>
{{- end }}
{{- end }}
