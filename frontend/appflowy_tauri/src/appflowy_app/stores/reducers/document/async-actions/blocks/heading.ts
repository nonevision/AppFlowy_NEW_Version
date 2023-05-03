import { createAsyncThunk } from '@reduxjs/toolkit';
import { Editor } from 'slate';
import { DocumentController } from '$app/stores/effects/document/document_controller';
import { BlockType } from '$app/interfaces/document';
import { turnToBlockThunk } from '$app_reducers/document/async-actions/turn_to';
import { getHeadingDataFromEditor } from '$app/utils/document/blocks/heading';

/**
 * transform to heading block
 * 1. insert heading block after current block
 * 2. move all children to parent after heading block, because heading block can't have children
 * 3. delete current block
 */
export const turnToHeadingBlockThunk = createAsyncThunk(
  'document/turnToHeadingBlock',
  async (payload: { id: string; editor: Editor; controller: DocumentController }, thunkAPI) => {
    const { id, editor, controller } = payload;
    const { dispatch } = thunkAPI;

    const data = getHeadingDataFromEditor(editor);
    if (!data) return;
    await dispatch(
      turnToBlockThunk({
        id,
        controller,
        type: BlockType.HeadingBlock,
        data,
      })
    );
  }
);
