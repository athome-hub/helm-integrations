{{/*
Expand the name of the chart.
*/}}
{{- define "postgres.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "postgres.fullname" -}}
{{- $name := .Chart.Name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "postgres.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
postgres labels
*/}}
{{- define "postgres.labels" -}}
helm.sh/chart: {{ include "postgres.chart" . }}
app: {{ printf "%s-db" .Values.name }}
{{ include "postgres.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "postgres.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgres.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "postgres.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "postgres.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Creates spec for postgres user
*/}}
{{- define "postgres.userDetails" -}}
{{- $password := randAlphaNum 16 -}}
{{- $endpoint := printf "%s-db-rw" .Values.name -}}
{{- $username := .Values.name -}}
{{- $database := printf "%s-db" .Values.name -}}
{{- with $password -}}
username: {{ $.Values.username }}
# username: {{ $username }}
# password: {{ . }}
password: {{ include "postgres.userPassword" . }}
# app_connection: {{ tpl $.Values.applicationConnection . }}

{{- end }}
{{- end }}

{{- define "postgres.userPassword" -}}
{{ randAlphaNum 16 -}}
{{- end -}}