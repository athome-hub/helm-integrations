{{/*
Expand the name of the chart.
*/}}
{{- define "authentik.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "authentik.fullname" -}}
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
{{- define "authentik.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
authentik labels
*/}}
{{- define "authentik.labels" -}}
helm.sh/chart: {{ include "authentik.chart" . }}
{{ include "authentik.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "authentik.selectorLabels" -}}
app.kubernetes.io/name: {{ printf "%s-auth-proxy" .Values.name }}
app.kubernetes.io/app: {{ printf "%s-auth-proxy" .Values.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "authentik.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "authentik.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Creates spec for authentik user
*/}}
{{- define "authentik.userDetails" -}}
{{- $password := randAlphaNum 16 -}}
{{- $endpoint := printf "%s-db-rw" .Values.name -}}
{{- $username := .Values.name -}}
{{- $database := printf "%s-db" .Values.name -}}
{{- with $password -}}
username: {{ $.Values.username }}
# username: {{ $username }}
# password: {{ . }}
password: {{ include "authentik.userPassword" . }}
# app_connection: {{ tpl $.Values.authentikConnection . }}

{{- end }}
{{- end }}

{{- define "authentik.userPassword" -}}
{{ randAlphaNum 16 -}}
{{- end -}}