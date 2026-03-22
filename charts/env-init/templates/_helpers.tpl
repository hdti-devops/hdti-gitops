############################
# SyncWave per application #
############################
{{- /* Get syncWave for a given app */ -}}
{{- define "env-init.syncWave" -}}
{{- $name := .name -}}
{{- $apps := .Values.apps -}}
{{- if hasKey $apps $name -}}
{{ index $apps $name "syncWave" }}
{{- else -}}
{{ index $apps "default" "syncWave" }}
{{- end -}}
{{- end -}}
####################################
# IgnoreDiffrences per application #
####################################
{{- /* Get ignoreDifferences for a given app */ -}}
{{- define "env-init.ignoreDifferences" -}}
{{- $name := .name -}}
{{- $apps := .Values.apps -}}
{{- if hasKey $apps $name -}}
{{ toYaml (index $apps $name "ignoreDifferences") | nindent 8 }}
{{- else -}}
{{ toYaml (index $apps "default" "ignoreDifferences") | nindent 8 }}
{{- end -}}
{{- end -}}