FROM nginx:1.27-alpine

# Fichier HTML statique
COPY index.html /usr/share/nginx/html/index.html

# Configuration nginx personnalisée
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
