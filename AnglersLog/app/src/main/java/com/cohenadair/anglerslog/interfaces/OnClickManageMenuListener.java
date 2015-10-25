package com.cohenadair.anglerslog.interfaces;

import java.util.UUID;

/**
 * An general interface for managing user defines.
 * Created by Cohen Adair on 2015-10-05.
 */
public interface OnClickManageMenuListener {
    void onClickMenuEdit(UUID objId);
    void onClickMenuTrash(UUID objId);
}
