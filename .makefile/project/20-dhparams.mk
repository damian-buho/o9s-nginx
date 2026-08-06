# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

PREREQUISITES += .container/user/app/tls/dhparams.pem

.container/user/app/tls/dhparams.pem:
	openssl dhparam -out .container/user/app/tls/dhparams.pem 2048