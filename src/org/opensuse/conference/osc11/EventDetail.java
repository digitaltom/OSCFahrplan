package org.opensuse.conference.osc11;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.Html;
import android.text.method.LinkMovementMethod;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

public class EventDetail extends Activity {

	private final String LOG_TAG = "Detail";
	private String title;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.detail);
        
        Intent intent = getIntent();
        
        TextView t = (TextView)findViewById(R.id.title);
        title = intent.getStringExtra("title");
        t.setText(title);
        
        t = (TextView)findViewById(R.id.subtitle);
        t.setText(intent.getStringExtra("subtitle"));
        
        t = (TextView)findViewById(R.id.speakers);
        t.setText(intent.getStringExtra("spkr"));
        
        t = (TextView)findViewById(R.id.abstractt);
        String s = intent.getStringExtra("abstract");
        s = s.replaceAll("\\[(.*?)\\]\\(([^ \\)]+).*?\\)", "<a href=\"$2\">$1</a>");   
        t.setText(Html.fromHtml(s), TextView.BufferType.SPANNABLE);
        t.setMovementMethod(new LinkMovementMethod());
        
        t = (TextView)findViewById(R.id.description);
        s = intent.getStringExtra("descr");
        s = s.replaceAll("\\[(.*?)\\]\\(([^ \\)]+).*?\\)", "<a href=\"$2\">$1</a>");   
        t.setText(Html.fromHtml(s), TextView.BufferType.SPANNABLE);
        t.setMovementMethod(new LinkMovementMethod());
        
        TextView l = (TextView)findViewById(R.id.linksSection);
        String links = intent.getStringExtra("links");
        t = (TextView)findViewById(R.id.links);
        
        if (links.length() > 0) {
        	Log.d(LOG_TAG, "show links");
        	l.setVisibility(View.VISIBLE);
        	t.setVisibility(View.VISIBLE);
        	links = links.replaceAll("\\),", ")<br>");
	        links = links.replaceAll("\\[(.*?)\\]\\(([^ \\)]+).*?\\)", "<a href=\"$2\">$1</a>");   
	        t.setText(Html.fromHtml(links), TextView.BufferType.SPANNABLE);
	        t.setMovementMethod(new LinkMovementMethod());
        } else {
        	l.setVisibility(View.GONE);
        	t.setVisibility(View.GONE);
        }
    }

}
