/*
 * Copyright (C) 2017 Jussi Nieminen, Finland
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import harbour.laufhelden 1.0
import com.pipacs.o2 1.0
import "../tools"
import "../tools/SharedResources.js" as SharedResources
import "../tools/JSTools.js" as JSTools

Page {
    id: stravaKudos
    property bool busy: false

    O2 {
        id: o2strava
        clientId: STRAVA_CLIENT_ID
        clientSecret: STRAVA_CLIENT_SECRET
        scope: "write"
        requestUrl: "https://www.strava.com/oauth/authorize"
        tokenUrl: "https://www.strava.com/oauth/token"
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        visible: parent.busy
        running: parent.busy
    }

    SilicaListView
    {
        anchors.fill: parent
        id: kudosList

        VerticalScrollDecorator {}

        header: PageHeader {
            title: qsTr("Kudos")
        }

        delegate: ListItem {
            id: listItem
            contentHeight: image.y + image.height + Theme.paddingMedium

            Image
            {
                id: image
                anchors.top: parent.top
                anchors.topMargin: Theme.paddingMedium
                x: Theme.paddingLarge
                width: Theme.paddingLarge * 3
                height: width
                source: kudosList.model[index]["profile_medium"]
            }
            Label
            {
                id: nameLabel
                width: parent.width - image.width - 2*Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: image.right
                anchors.leftMargin: Theme.paddingMedium
                truncationMode: TruncationMode.Fade
                text: kudosList.model[index]["firstname"] + " " + kudosList.model[index]["lastname"]
            }
        }
    }

    function loadKudos(id) {
        if (!o2strava.linked){
            console.log("Not linked to Strava");
            return;
        }

        busy = true;

        var xmlhttp = new XMLHttpRequest();

        JSTools.stravaGet(xmlhttp, "https://www.strava.com/api/v3/activities/" + id + "/kudos", o2strava.token , function(){
            busy = true;
            console.log("Ready state changed:", xmlhttp.readyState, xmlhttp.responseType, xmlhttp.responseText, xmlhttp.status, xmlhttp.statusText);
            if (xmlhttp.readyState===4 && xmlhttp.status===200){
                console.log("Get Response:", xmlhttp.responseText);
                kudosList.model = JSON.parse(xmlhttp.responseText);
            }
            busy = false;
        })
    }
}
