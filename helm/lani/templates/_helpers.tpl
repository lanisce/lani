{{/*
Expand the name of the chart.
*/}}
{{- define "lani.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lani.fullname" -}}
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
{{- define "lani.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lani.labels" -}}
helm.sh/chart: {{ include "lani.chart" . }}
{{ include "lani.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "lani.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lani.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "lani.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "lani.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the secret to use
*/}}
{{- define "lani.secretName" -}}
{{- if .Values.secrets.external }}
{{- .Values.secrets.externalSecretName | default (printf "%s-external" (include "lani.fullname" .)) }}
{{- else }}
{{- printf "%s-secrets" (include "lani.fullname" .) }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "lani.postgresql.host" -}}
{{- if eq .Values.postgresql.type "internal" }}
{{- printf "%s-postgresql" (include "lani.fullname" .) }}
{{- else if eq .Values.postgresql.type "external" }}
{{- .Values.postgresql.external.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "lani.postgresql.port" -}}
{{- if eq .Values.postgresql.type "internal" }}
{{- 5432 }}
{{- else if eq .Values.postgresql.type "external" }}
{{- .Values.postgresql.external.port }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database
*/}}
{{- define "lani.postgresql.database" -}}
{{- if eq .Values.postgresql.type "internal" }}
{{- .Values.postgresql.internal.auth.database }}
{{- else if eq .Values.postgresql.type "external" }}
{{- .Values.postgresql.external.database }}
{{- end }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "lani.postgresql.username" -}}
{{- if eq .Values.postgresql.type "internal" }}
{{- .Values.postgresql.internal.auth.username }}
{{- else if eq .Values.postgresql.type "external" }}
{{- .Values.postgresql.external.username }}
{{- end }}
{{- end }}

{{/*
Redis host
*/}}
{{- define "lani.redis.host" -}}
{{- if eq .Values.redis.type "internal" }}
{{- printf "%s-redis-master" (include "lani.fullname" .) }}
{{- else if eq .Values.redis.type "external" }}
{{- .Values.redis.external.host }}
{{- end }}
{{- end }}

{{/*
Redis port
*/}}
{{- define "lani.redis.port" -}}
{{- if eq .Values.redis.type "internal" }}
{{- 6379 }}
{{- else if eq .Values.redis.type "external" }}
{{- .Values.redis.external.port }}
{{- end }}
{{- end }}

{{/*
Database URL
*/}}
{{- define "lani.databaseUrl" -}}
{{- if eq .Values.postgresql.type "internal" }}
postgres://{{ .Values.postgresql.internal.auth.username }}:$(POSTGRES_PASSWORD)@{{ include "lani.postgresql.host" . }}:{{ include "lani.postgresql.port" . }}/{{ include "lani.postgresql.database" . }}
{{- else if eq .Values.postgresql.type "external" }}
postgres://{{ .Values.postgresql.external.username }}:$(POSTGRES_PASSWORD)@{{ include "lani.postgresql.host" . }}:{{ include "lani.postgresql.port" . }}/{{ include "lani.postgresql.database" . }}?sslmode={{ .Values.postgresql.external.sslMode }}
{{- end }}
{{- end }}

{{/*
Redis URL
*/}}
{{- define "lani.redisUrl" -}}
{{- if eq .Values.redis.type "internal" }}
redis://:$(REDIS_PASSWORD)@{{ include "lani.redis.host" . }}:{{ include "lani.redis.port" . }}/0
{{- else if eq .Values.redis.type "external" }}
redis://:$(REDIS_PASSWORD)@{{ include "lani.redis.host" . }}:{{ include "lani.redis.port" . }}/{{ .Values.redis.external.database }}
{{- end }}
{{- end }}

{{/*
Storage class
*/}}
{{- define "lani.storageClass" -}}
{{- if .Values.global.storageClass }}
{{- .Values.global.storageClass }}
{{- else if .Values.storage.storageClass }}
{{- .Values.storage.storageClass }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Image pull secrets
*/}}
{{- define "lani.imagePullSecrets" -}}
{{- if .Values.global.imagePullSecrets }}
{{- range .Values.global.imagePullSecrets }}
- name: {{ . }}
{{- end }}
{{- else if .Values.image.pullSecrets }}
{{- range .Values.image.pullSecrets }}
- name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Validate configuration
*/}}
{{- define "lani.validateConfig" -}}
{{- if and (ne .Values.postgresql.type "internal") (ne .Values.postgresql.type "external") }}
{{- fail "postgresql.type must be either 'internal' or 'external'" }}
{{- end }}
{{- if and (ne .Values.redis.type "internal") (ne .Values.redis.type "external") }}
{{- fail "redis.type must be either 'internal' or 'external'" }}
{{- end }}
{{- if and (eq .Values.postgresql.type "external") (not .Values.postgresql.external.host) }}
{{- fail "postgresql.external.host is required when postgresql.type is 'external'" }}
{{- end }}
{{- if and (eq .Values.redis.type "external") (not .Values.redis.external.host) }}
{{- fail "redis.external.host is required when redis.type is 'external'" }}
{{- end }}
{{- end }}

{{/*
Common environment variables
*/}}
{{- define "lani.commonEnv" -}}
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: POD_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: DATABASE_URL
  value: {{ include "lani.databaseUrl" . | quote }}
- name: REDIS_URL
  value: {{ include "lani.redisUrl" . | quote }}
{{- if eq .Values.postgresql.type "internal" }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "lani.fullname" . }}-postgresql
      key: password
{{- else if eq .Values.postgresql.type "external" }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "lani.secretName" . }}
      key: postgres-password
{{- end }}
{{- if eq .Values.redis.type "internal" }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "lani.fullname" . }}-redis
      key: redis-password
{{- else if eq .Values.redis.type "external" }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "lani.secretName" . }}
      key: redis-password
{{- end }}
{{- range $key, $value := .Values.env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
Common volume mounts
*/}}
{{- define "lani.commonVolumeMounts" -}}
{{- if .Values.storage.enabled }}
- name: storage
  mountPath: /app/storage
{{- end }}
- name: tmp
  mountPath: /app/tmp
- name: log
  mountPath: /app/log
{{- end }}

{{/*
Common volumes
*/}}
{{- define "lani.commonVolumes" -}}
{{- if .Values.storage.enabled }}
- name: storage
  persistentVolumeClaim:
    claimName: {{ include "lani.fullname" . }}-storage
{{- end }}
- name: tmp
  emptyDir: {}
- name: log
  emptyDir: {}
{{- end }}

{{/*
Security context
*/}}
{{- define "lani.securityContext" -}}
runAsNonRoot: {{ .Values.securityContext.runAsNonRoot }}
runAsUser: {{ .Values.securityContext.runAsUser }}
fsGroup: {{ .Values.securityContext.fsGroup }}
{{- end }}

{{/*
Container security context
*/}}
{{- define "lani.containerSecurityContext" -}}
allowPrivilegeEscalation: {{ .Values.securityContext.allowPrivilegeEscalation }}
readOnlyRootFilesystem: {{ .Values.securityContext.readOnlyRootFilesystem }}
runAsNonRoot: {{ .Values.securityContext.runAsNonRoot }}
runAsUser: {{ .Values.securityContext.runAsUser }}
capabilities:
  drop:
    {{- range .Values.securityContext.capabilities.drop }}
    - {{ . }}
    {{- end }}
{{- end }}
