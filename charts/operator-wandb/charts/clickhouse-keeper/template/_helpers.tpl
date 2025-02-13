{{- define "clickhouse-keeper.fullname" -}}
{{- printf "%s-%s" .Release.Name "clickhouse-keeper" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "clickhouse-keeper.labels" -}}
helm.sh/chart: {{ include "clickhouse-keeper.chart" . }}
{{ include "clickhouse-keeper.selectorLabels" . }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "clickhouse-keeper.selectorLabels" -}}
app.kubernetes.io/name: {{ include "clickhouse-keeper.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "clickhouse-keeper.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "clickhouse-keeper.chart" -}}
{{- .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}
