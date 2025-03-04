{{/*
Expand the name of the chart.
*/}}
{{- define "dragonfly.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dragonfly.fullname" -}}
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
{{- define "dragonfly.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
dragonfly labels
*/}}
{{- define "dragonfly.labels" -}}
helm.sh/chart: {{ include "dragonfly.chart" . }}
app: {{ printf "%s-db" .Values.name }}
{{ include "dragonfly.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dragonfly.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dragonfly.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dragonfly.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dragonfly.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Creates spec for dragonfly user
*/}}
{{- define "dragonfly.userDetails" -}}
{{- $password := randAlphaNum 16 -}}
{{- $endpoint := printf "%s-db-rw" .Values.name -}}
{{- $username := .Values.name -}}
{{- $database := printf "%s-db" .Values.name -}}
{{- with $password -}}
username: {{ $.Values.username }}
# username: {{ $username }}
# password: {{ . }}
password: {{ include "dragonfly.userPassword" . }}
# app_connection: {{ tpl $.Values.applicationConnection . }}

{{- end }}
{{- end }}

{{- define "dragonfly.userPassword" -}}
{{ randAlphaNum 16 -}}
{{- end -}}