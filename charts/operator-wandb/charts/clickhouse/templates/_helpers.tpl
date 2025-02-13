{{- /*
Generate a name using the release name and the chart name.
*/ -}}
{{- define "clickhouse.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
Generate a name using the release name and the provided name.
*/ -}}
{{- define "clickhouse.name" -}}
{{- printf "%s-%s" .Release.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
Generate a name using the release name and the chart name, with a suffix.
*/ -}}
{{- define "clickhouse.fullnameWithSuffix" -}}
{{- printf "%s-%s-%s" .Release.Name .Chart.Name .Values.global.suffix | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
Generate labels common to all resources.
*/ -}}
{{- define "clickhouse.labels" -}}
app.kubernetes.io/name: {{ include "clickhouse.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- /*
Generate selector labels common to all resources.
*/ -}}
{{- define "clickhouse.selectorLabels" -}}
app.kubernetes.io/name: {{ include "clickhouse.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
